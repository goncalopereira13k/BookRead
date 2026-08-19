"use client";
import React, { useState } from 'react';
import { Button, Form, FloatingLabel } from 'react-bootstrap';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { loginUser } from '../services/authService';

import './login.css';
import 'bootstrap/dist/css/bootstrap.min.css';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [errors, setErrors] = useState<{ email?: string; password?: string }>({});
  const router = useRouter(); 

  const validateForm = () => {
    const newErrors: { email?: string; password?: string } = {};
    if (!email)
      newErrors.email = 'Email is required';
    else if (!/\S+@\S+\.\S+/.test(email))
      newErrors.email = 'Email is invalid';

    if (!password)
      newErrors.password = 'Password is required';
    return newErrors;
  }

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();

    const formErrors = validateForm();
    if (Object.keys(formErrors).length > 0) {
      setErrors(formErrors);
      return;
    }

    try {
      const userData = await loginUser(email, password);
      localStorage.setItem("token", userData.token); // Armazena o token no localStorage
      // vai pa página principal se o login for bem sucedido
      router.push("/");
    } catch (error: any) {
      setErrors({ password: error.message });
    }
  };

  const handleEmailChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setEmail(event.target.value);
  }

  const handlePasswordChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setPassword(event.target.value);
  }


return (
  <div className="login-wrapper">
    <div className="login-form-container">
      <h2 className="login-title">Login</h2>
      <Form onSubmit={handleSubmit} noValidate>
        <FloatingLabel
          controlId="formEmail"
          label="Email address"
          className="mb-3"
        >
          <Form.Control
            type="email"
            name="email"
            placeholder="Enter email"
            value={email}
            onChange={handleEmailChange}
            isInvalid={!!errors.email}
            className="form-control"
          />
          <Form.Control.Feedback type="invalid">
            {errors.email}
          </Form.Control.Feedback>
        </FloatingLabel>

        <FloatingLabel
          controlId="formPassword"
          label="Password"
          className="mb-3"
        >
          <Form.Control
            type="password"
            name="password"
            placeholder="Password"
            value={password}
            onChange={handlePasswordChange}
            isInvalid={!!errors.password}
            className="form-control"
          />
          <Form.Control.Feedback type="invalid">
            {errors.password}
          </Form.Control.Feedback>
        </FloatingLabel>

        <div className="button-group">
       
          <Button variant="primary" type="submit" className="login-button">
            Login
          </Button>
        </div>
      </Form>
    </div>
  </div>
);
}