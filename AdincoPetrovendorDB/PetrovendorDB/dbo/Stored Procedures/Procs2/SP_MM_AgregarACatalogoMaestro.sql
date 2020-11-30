-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_AgregarACatalogoMaestro]
@IdSubFamilia     INT,
@DescripcionCorta NVARCHAR(MAX),
@DescripcionLarga NVARCHAR(MAX),
@UMB              INT,
@IdTipoMoneda     INT,
@Precio           MONEY,
@IdTipoCatalogo   INT,  
@IdProveedor      INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @COD_SUBFAMILIA NVARCHAR(20) = (SELECT CodSubFamilia FROM PV_MM_MaterialSubFamilia WHERE IdSubFamilia = @IdSubFamilia)

	INSERT INTO MM_MAESTRO(
	 [IdTipoCatalogoMaestro]
    ,[IdSubFamilia]
    ,[CodSubFamilia]
    ,[TextoCorto]
    ,[TextoLargo]
    ,[IdUnidad]
    ,[IdMoneda]
    ,[Precio]
	,[CreadoPor]
	)
	VALUES(
	@IdTipoCatalogo,
	@IdSubFamilia,
	@COD_SUBFAMILIA,
	@DescripcionCorta,
	@DescripcionLarga,
	@UMB,
	@IdTipoMoneda,	
	@Precio,  
	@IdProveedor
	)

	SELECT @@IDENTITY


END

