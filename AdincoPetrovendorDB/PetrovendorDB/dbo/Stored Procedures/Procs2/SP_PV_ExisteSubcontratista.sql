USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_PV_ExisteSubcontratista'
)
    DROP PROCEDURE SP_PV_ExisteSubcontratista;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Miguel
-- Create date: 
-- Description:	
-- =============================================
-- Author:  <Alexander Gomez>  
-- Create date: 22/02/2024
-- Description: se agregan estandares de desarrollo
-- =============================================  
CREATE PROCEDURE [dbo].[SP_PV_ExisteSubcontratista] 
	-- Add the parameters for the stored procedure here
	@RFC nvarchar(MAX) 

AS
BEGIN
	DECLARE @ENCONTRADOS AS INT
	
	SELECT   @ENCONTRADOS =  count  (*)  
	FROM            S_Proveedor S (NOLOCK)
	WHERE UPPER(RTRIM(S.RFC)) =UPPER(RTRIM(@RFC));
	
	IF (ISNULL(@ENCONTRADOS,0) > 0) 
	BEGIN
		SELECT        S.IdProveedor, S.RazonSocial
		FROM            S_Proveedor S (NOLOCK)
		WHERE UPPER(RTRIM(S.RFC)) =UPPER(RTRIM(@RFC))
	END
	ELSE
	BEGIN
		SELECT  0 AS IdSubcontratista, 'NO EXISTE' AS RazonSocial
	END
		
END

