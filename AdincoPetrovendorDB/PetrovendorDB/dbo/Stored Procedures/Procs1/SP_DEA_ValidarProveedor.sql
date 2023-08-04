USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_DEA_ValidarProveedor'
)
    DROP PROCEDURE SP_DEA_ValidarProveedor;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Luis David De La Cruz Bautista
-- Update: 25-01-2021
-- Description:	issue #930/ Optimización de sp
-- =============================================
CREATE PROCEDURE [dbo].[SP_DEA_ValidarProveedor]
	-- Add the parameters for the stored procedure here
	@IdProveedor int, 
	@IdUsuario int
AS
BEGIN
	DECLARE @RFC_ACTUAL NVARCHAR(200), @EXISTE_RFC INT;

	set @RFC_ACTUAL = (SELECT RFC FROM dbo.S_Proveedor (NOLOCK) WHERE IdProveedor=@IdProveedor)
	set @EXISTE_RFC = (SELECT COUNT(IdProveedor) 
						FROM DEA_Proveedor (NOLOCK)
						WHERE RTRIM(LTRIM(RFC))=RTRIM(LTRIM(@RFC_ACTUAL)) 
						AND Activo = 1)

	IF ISNULL(@EXISTE_RFC,0)  >0 
	BEGIN 
		IF @RFC_ACTUAL = 'PAM140722DK6'
		BEGIN
			SELECT 'AMATITLAN'
		END
		ELSE
		BEGIN
			SELECT 'CAMBIAR_PROCESO'
		END
	END 
	ELSE 
	BEGIN 
			SELECT 'SEGUIR_PROCESO'
		
	END 
END