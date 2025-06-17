import axios from 'axios'
import { trackApiRequest, trackError } from './datadog'

// Create axios instance with interceptors
const api = axios.create({
  baseURL: process.env.VITE_API_BASE_URL || 'http://localhost:3000',
  timeout: 10000
})

// Request interceptor
api.interceptors.request.use(
  (config) => {
    // Add request start time
    config.metadata = { startTime: new Date() }
    return config
  },
  (error) => {
    trackError(error, { type: 'request_error' })
    return Promise.reject(error)
  }
)

// Response interceptor
api.interceptors.response.use(
  (response) => {
    const endTime = new Date()
    const startTime = response.config.metadata?.startTime
    const duration = startTime ? endTime.getTime() - startTime.getTime() : 0

    trackApiRequest(
      response.config.url || '',
      response.config.method || 'GET',
      response.status,
      duration
    )

    return response
  },
  (error) => {
    const endTime = new Date()
    const startTime = error.config?.metadata?.startTime
    const duration = startTime ? endTime.getTime() - startTime.getTime() : 0

    trackApiRequest(
      error.config?.url || '',
      error.config?.method || 'GET',
      error.response?.status || 0,
      duration
    )

    trackError(error, { 
      type: 'response_error',
      status: error.response?.status,
      duration
    })

    return Promise.reject(error)
  }
)

export default api 