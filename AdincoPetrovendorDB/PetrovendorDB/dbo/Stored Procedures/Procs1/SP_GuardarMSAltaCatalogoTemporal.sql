-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_GuardarMSAltaCatalogoTemporal]

@Descripcionlarga NVARCHAR(MAX),
@DescripcionCorta NVARCHAR(MAX),
@UMB              INT,
@IdTipoMoneda     INT,
@Precio           MONEY,
@ImagenMaterial   NVARCHAR(MAX),
@FichaTecnica     NVARCHAR(MAX),
@IdTipoCatalogo   INT,
@CreadoPor        INT,
@IdProveedor      INT,
@IdSugerencia     INT


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO PV_MM_AltaCatalogoProveedorTemp(
       [DescripcionCorta]
      ,[DescripcionLarga]
      ,[UMB]
      ,[IdTipoMoneda]
      ,[Precio]
      ,[ImagenMaterial]
      ,[FichaTecnica]
      ,[FechaRegistro]
      ,[IsActivo]
      ,[IdTipoCatalogo]
      ,[CreadoPor]
      ,[IdProveedor]
      ,[EstatusAprobacion]
	  ,[IdSugerencia]
	)
	VALUES(
		@DescripcionCorta,
		@DescripcionLarga,
		@UMB,
		@IdTipoMoneda,
		@Precio,
		@ImagenMaterial,
		@FichaTecnica,
		GETDATE(),
		1,
		@IdTipoCatalogo,
		@CreadoPor,
		@IdProveedor,
		1,
		@IdSugerencia
	)

	SELECT @@IDENTITY

END

