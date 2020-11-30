-- =============================================
-- Author: DANIEL AC
-- Create date: 18/08/2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[PE_SP_AltaDistribuidorAutorizadoDeV2] 
	-- Add the parameters for the stored procedure here

@IdProveedor	int ,
@IdUsuario int, 
@NombreEmpresa nvarchar(MAX),
@FechaInicioDistribucion DATETIME,
@RFC nvarchar(300),
--@DocumentoAutorizacion nvarchar(max),
@Descripcion nvarchar(max),
@Correo nvarchar(50),
@Telefono nvarchar(10)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	INSERT INTO [dbo].[PV_DistribuidorAutorizado]
	([IdProveedor],
	[IdCreadoPor],
	[CreadoEl],
	[RFC],
	[NombreEmpresa],
	[FechaInicioDistribucion],
	[Activo],
	[Descripcion],
	Correo,
	Telefono)
	VALUES(
	@IdProveedor,
	@IdUsuario,
	GETDATE(),
	@RFC,
	@NombreEmpresa,
	@FechaInicioDistribucion,
	1,
	@Descripcion,
	@Correo,
	@Telefono)
	

	--DECLARE @IdDistribuidorAutorizadoDe int= (SELECT @@Identity)

	--INSERT INTO [dbo].[S_Documento]
	--([IdTipoDocumento],
	--[IdProveedor],
	--[Activo],
	--[Documento],
	--[CreadoPor])
	--VALUES(
	--21,
	--@IdProveedor,
	--1,
	--@DocumentoAutorizacion,
	--@IdUsuario)

	--DECLARE @IdDocumento int = (SELECT @@Identity)

	--UPDATE [PV_DistribuidorAutorizado]
	--SET [IdDocumento]=@IdDocumento
	--WHERE [IdDistribuidorAutorizado]=@IdDistribuidorAutorizadoDe

	--SELECT 'SUCCESS'
END
 
	


