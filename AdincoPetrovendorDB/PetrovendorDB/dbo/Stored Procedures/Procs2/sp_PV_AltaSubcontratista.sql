USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_PV_AltaSubcontratista'
)
    DROP PROCEDURE sp_PV_AltaSubcontratista;
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
-- Description: se agregan estandares de desarrollo y mejoras
-- =============================================  
CREATE PROCEDURE [dbo].[sp_PV_AltaSubcontratista] 
	-- Add the parameters for the stored procedure here
	
	@RFC	nvarchar(MAX) ,
	@RazonSocial	nvarchar(MAX) ,
	@NacionalidadID	int ,
	@NombreComercial	nvarchar(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @ENCONTRADOS AS INT
	
	SELECT   @ENCONTRADOS =  count  (*)  
	FROM            S_Proveedor S (NOLOCK)
	WHERE UPPER(RTRIM(S.RFC)) =UPPER(RTRIM(@RFC));

	IF (ISNULL(@ENCONTRADOS,0) = 0) 
	BEGIN
		
		INSERT INTO [dbo].[S_Proveedor]
           ([RFC]
           ,[RazonSocial]
           ,[IdNacionalidad]
           ,[Alias],
		   IsEliminado
)
     VALUES
           (
			@RFC,
			@RazonSocial,
			@NacionalidadID,
			@NombreComercial,
			0
			);

	END

	SELECT @@IDENTITY  AS ID , 
			concat('El proveedor se ha actualizado exitosamente con el id ' , @@IDENTITY)  as MSG


END
