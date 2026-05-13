-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DG_ConsultarDomiciliosReporte]
@IdProveedor int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON; 
	-- D.NoExterior
	--D.TipoViabilidad,D.NombreViabilidad

	SELECT IdDomicilio,D.IdTipoDomicilio,('Calle ' + D.Calle + ' #' + cast(D.NoInterior as varchar(30)) + ' Col. ' + D.Colonia + ',' + D.Municipio + ',' + D.Estado  + ',' + cast(D.IdPais as varchar(30)) + ' ' +
	'CP ' + cast(D.CodigoPostal as varchar(30))) as direccion
	FROM [dbo].[DG_Domicilio] AS D
	INNER JOIN [dbo].[DG_TipoDomicilio] AS TD ON TD.IdTipoDomicilio = D.IdTipoDomicilio
	INNER JOIN [dbo].[PV_PaisRepublica] AS PR ON D.IdPais= PR.id
	INNER JOIN [dbo].[S_Proveedor] AS P ON P.IdProveedor = D.IdProveedor 
	WHERE P.IdProveedor = @IdProveedor AND D.IdTipoDomicilio = 1 AND D.Activo = 1


END

