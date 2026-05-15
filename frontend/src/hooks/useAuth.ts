import { useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { useMutation } from '@tanstack/react-query';
import { login as loginApi, register as registerApi } from '../api/auth';
import type { LoginRequest, RegisterRequest } from '../types';

export function useAuth() {
  const navigate = useNavigate();

  const isAuthenticated = !!localStorage.getItem('et_token');

  const loginMutation = useMutation({
    mutationFn: (data: LoginRequest) => loginApi(data),
    onSuccess: (res) => {
      localStorage.setItem('et_token', res.token);
      navigate('/');
    },
  });

  const registerMutation = useMutation({
    mutationFn: (data: RegisterRequest) => registerApi(data),
    onSuccess: (res) => {
      localStorage.setItem('et_token', res.token);
      navigate('/');
    },
  });

  const logout = useCallback(() => {
    localStorage.removeItem('et_token');
    navigate('/login');
  }, [navigate]);

  return {
    isAuthenticated,
    login: loginMutation,
    register: registerMutation,
    logout,
  };
}
