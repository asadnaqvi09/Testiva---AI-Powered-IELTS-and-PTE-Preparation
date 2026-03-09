import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import morgan from 'morgan';

dotenv.config();
const app = express();

const port = 3000;

// Middlewares
app.use(cors());
app.use(helmet());
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.get('/', (req,res)=>{
    res.send("Api Testing");
})

// Server Calling
app.listen(port, ()=> {
    console.log(`Server is running on port ${port}`);
})