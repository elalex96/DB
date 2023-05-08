-- =============================================
-- Author:		DANIEL AC
-- Create date: 05/06/2017
-- Description:	CONSULTAR DOMICILIO FISCAL , MATRIZ O SUCURSAL
-- =============================================
CREATE PROCEDURE [dbo].[SP_DG_ConsultarDomicilioFiscal]
	-- Add the parameters for the stored procedure here
	@IdProveedor int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	SELECT IdDomicilio, 
	D.IdTipoDomicilio,
	D.Calle,
	D.NoExterior, 
	D.NoInterior,
	D.Colonia,
	D.Municipio, 
	D.Estado, 
	D.IdPais, 
	D.CodigoPostal,
	D.TipoViabilidad,
	D.NombreViabilidad
	FROM [dbo].[DG_Domicilio] AS D
	INNER JOIN [dbo].[DG_TipoDomicilio] AS TD ON TD.IdTipoDomicilio = D.IdTipoDomicilio
	INNER JOIN [dbo].[PV_PaisRepublica] AS PR ON D.IdPais= PR.id
	INNER JOIN [dbo].[S_Proveedor] AS P ON P.IdProveedor = D.IdProveedor 
	WHERE P.IdProveedor = @IdProveedor
	AND D.IdTipoDomicilio= 1
 
  ---- IdTipoDomicilio DomicilioFiscal = 1


END

