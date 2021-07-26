USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_CF_GuardarEdoCuenta'
)
    DROP PROCEDURE SP_CF_GuardarEdoCuenta;
/****** Object:  StoredProcedure [dbo].[SP_CF_GuardarEdoCuenta]    Script Date: 20/07/2021 03:13:02 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:           Daniel AC
-- Create date: 26-09-2019
-- Description: Se agregaron parametros de referencia al S3
-- =============================================
CREATE PROCEDURE [dbo].[SP_CF_GuardarEdoCuenta]
	-- Add the parameters for the stored procedure here
	@IdProveedor int,
	@EdoCuenta nvarchar(max),
	@IdUsuario int,
	@NombreDoc varchar(max),
	@Año INT,
	@Carpeta NVARCHAR(MAX),
	@Mime NVARCHAR(MAX),
	@Identificador NVARCHAR(MAX),
	@Extension NVARCHAR(MAX),
	@Bucket  NVARCHAR(MAX)
AS
BEGIN
	
	INSERT INTO CF_EdoCuentaDocumentos
		(IdProveedor, EdoCuenta, Año, SubidoPor, FechaCarga, NombreDoc, Carpeta, Mime, Identificador, Extension, Bucket)
	values(@IdProveedor, '', @Año, @IdUsuario, GETDATE(), @NombreDoc, @Carpeta,@Mime, @Identificador, @Extension,@Bucket)

END