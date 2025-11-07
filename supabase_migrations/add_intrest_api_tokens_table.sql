-- Migration: Add Intrest API Tokens Table
-- Description: Creates table to store Intrest API (Food Analysis API) authentication tokens
--              linked to user accounts for persistence across devices

-- Create intrest_api_tokens table
CREATE TABLE IF NOT EXISTS public.intrest_api_tokens (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  access_token text NOT NULL,
  refresh_token text NOT NULL,
  expires_at timestamp with time zone NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT intrest_api_tokens_pkey PRIMARY KEY (id),
  CONSTRAINT intrest_api_tokens_user_id_fkey FOREIGN KEY (user_id) 
    REFERENCES public.users(id) ON DELETE CASCADE,
  CONSTRAINT intrest_api_tokens_user_id_unique UNIQUE (user_id)
);

-- Create index on user_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_intrest_api_tokens_user_id 
  ON public.intrest_api_tokens(user_id);

-- Create index on expires_at for token cleanup queries
CREATE INDEX IF NOT EXISTS idx_intrest_api_tokens_expires_at 
  ON public.intrest_api_tokens(expires_at);

-- Enable Row Level Security
ALTER TABLE public.intrest_api_tokens ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only view their own tokens
CREATE POLICY "Users can view own tokens"
  ON public.intrest_api_tokens
  FOR SELECT
  USING (auth.uid() = user_id);

-- RLS Policy: Users can insert their own tokens
CREATE POLICY "Users can insert own tokens"
  ON public.intrest_api_tokens
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can update their own tokens
CREATE POLICY "Users can update own tokens"
  ON public.intrest_api_tokens
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can delete their own tokens
CREATE POLICY "Users can delete own tokens"
  ON public.intrest_api_tokens
  FOR DELETE
  USING (auth.uid() = user_id);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_intrest_api_tokens_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to update updated_at on row update
CREATE TRIGGER update_intrest_api_tokens_updated_at
  BEFORE UPDATE ON public.intrest_api_tokens
  FOR EACH ROW
  EXECUTE FUNCTION public.update_intrest_api_tokens_updated_at();

-- Add comment to table
COMMENT ON TABLE public.intrest_api_tokens IS 
  'Stores Intrest API (Food Analysis API) authentication tokens linked to user accounts for persistence across devices';

-- Add comments to columns
COMMENT ON COLUMN public.intrest_api_tokens.user_id IS 
  'Foreign key to users table - links token to user account';
COMMENT ON COLUMN public.intrest_api_tokens.access_token IS 
  'JWT access token from Intrest API';
COMMENT ON COLUMN public.intrest_api_tokens.refresh_token IS 
  'Refresh token string from Intrest API';
COMMENT ON COLUMN public.intrest_api_tokens.expires_at IS 
  'Token expiration timestamp (converted from expiresIn milliseconds)';

