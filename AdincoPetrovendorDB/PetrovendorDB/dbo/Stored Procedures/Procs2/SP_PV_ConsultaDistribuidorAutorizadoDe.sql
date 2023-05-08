-- =============================================
-- Author: DANIEL AC
-- Create date: 18/08/2017
-- Description:	08/05/2018 ACTUALIZACIÓN DE REFERENCIAS DE S_DOCUMENTO A S_DOCUMENTO_S3
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ConsultaDistribuidorAutorizadoDe] 
	-- Add the parameters for the stored procedure here

@IdProveedor	int,
@ConsultaGrid nvarchar(300)
--@Nombre nvarchar(50),
--@Correo nvarchar(50),
--@Telefono nvarchar(10)


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	
	IF @ConsultaGrid = 'Grid'
	BEGIN
		SELECT IdDistribuidorAutorizado,
		 NombreEmpresa,
		 RFC, 
		 FechaInicioDistribucion,
		 DA.Descripcion,
		 Nombre,
		 Correo,
		 Telefono
		FROM [dbo].[PV_DistribuidorAutorizado] AS DA
		INNER JOIN dbo.S_Documento_S3 AS D ON D.IdDocumento = DA.IdDocumento
		WHERE DA.IdProveedor= @IdProveedor AND DA.Activo=1
	END 
	
	IF @ConsultaGrid = 'Modal'
	BEGIN
	     SELECT 
		 DA.IdDistribuidorAutorizado,
		 DA.NombreEmpresa,
		 DA.RFC, 
		 DA.FechaInicioDistribucion,
		 DA.Descripcion, 
		 D.Documento,
		 Nombre,
		 Correo,
		 Telefono,
		 'Distribuidor Autorizado '+ NombreEmpresa +'.pdf'
		FROM [dbo].[PV_DistribuidorAutorizado] AS DA
		INNER JOIN dbo.S_Documento_S3 AS D ON D.IdDocumento = DA.IdDocumento
		WHERE DA.IdProveedor= @IdProveedor AND DA.Activo=1
	END 

END