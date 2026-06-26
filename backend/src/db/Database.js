const mysql = require('mysql2/promise');
const env = require('../config/env');

class Database {
  constructor() {
    this.pool = null;
  }

  async connect() {
    try {
      this.pool = await mysql.createPool({
        host: env.DB_HOST,
        port: env.DB_PORT,
        user: env.DB_USER,
        password: env.DB_PASSWORD,
        waitForConnections: true,
        connectionLimit: 10,
        queueLimit: 0,
      });
      console.log('✓ Database connection pool created');
    } catch (error) {
      console.error('✗ Failed to create connection pool:', error.message);
      throw error;
    }
  }

  async createDatabase() {
    const connection = await this.pool.getConnection();
    try {
      await connection.query(`CREATE DATABASE IF NOT EXISTS ${env.DB_NAME}`);
      console.log(`✓ Database '${env.DB_NAME}' created or already exists`);
      connection.release();

      // Close old pool and create new one with database specified
      await this.pool.end();
      this.pool = await mysql.createPool({
        host: env.DB_HOST,
        port: env.DB_PORT,
        user: env.DB_USER,
        password: env.DB_PASSWORD,
        database: env.DB_NAME,
        waitForConnections: true,
        connectionLimit: 10,
        queueLimit: 0,
      });
      console.log(`✓ Switched to database '${env.DB_NAME}'`);
    } catch (error) {
      console.error('✗ Failed to create database:', error.message);
      throw error;
    }
  }

  async createTables() {
    const schema = require('./schema');
    const tables = schema.getTables();

    for (const tableName in tables) {
      try {
        await this.execute(tables[tableName]);
        console.log(`✓ Table '${tableName}' created or already exists`);
      } catch (error) {
        console.error(`✗ Failed to create table '${tableName}':`, error.message);
        throw error;
      }
    }
  }

  async execute(sql, params = []) {
    if (!this.pool) throw new Error('Database not connected');
    try {
      const [result] = await this.pool.execute(sql, params);
      return result;
    } catch (error) {
      console.error('SQL Error:', error.message, '\nSQL:', sql);
      throw error;
    }
  }

  async query(sql, params = []) {
    if (!this.pool) throw new Error('Database not connected');
    try {
      const [rows] = await this.pool.query(sql, params);
      return rows;
    } catch (error) {
      console.error('SQL Error:', error.message, '\nSQL:', sql);
      throw error;
    }
  }

  async init(retries = 30) {
    for (let attempt = 1; attempt <= retries; attempt++) {
      try {
        await this.connect();
        await this.createDatabase();
        await this.createTables();
        console.log('✓ Database initialization completed successfully');
        return;
      } catch (error) {
        if (attempt < retries) {
          console.log(`Database not ready, retrying (${attempt}/${retries})...`);
          await new Promise(resolve => setTimeout(resolve, 2000));
        } else {
          console.error('✗ Database initialization failed after', retries, 'attempts');
          throw error;
        }
      }
    }
  }

  async close() {
    if (this.pool) {
      await this.pool.end();
      console.log('✓ Database connection pool closed');
    }
  }
}

module.exports = new Database();
