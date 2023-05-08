-- =============================================
-- Author:		DANIEL AC
-- Create date: 05/06/2017
-- Description:	CONSULTAR DOMICILIO FISCAL , MATRIZ O SUCURSAL
-- =============================================
-- =============================================
-- Update:		Pedro Acuña
-- Create date: 01/11/2017
-- Description:	se agrega el filtro que muestre solo los activos y se quita el filtro que solo se muestre los domicilios fiscales
-- =============================================
-- =============================================
-- Update:		Pedro Acuña
-- Modified date: 15/02/2018
-- Description:	se modifica a left join ya que cuando se registra por primera vez puede registrarse un domicilio como fiscal en automatico sin datos
-- =============================================
CREATE PROCEDURE [dbo].[SP_DG_Domicilio]
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
	LEFT JOIN [dbo].[DG_TipoDomicilio] AS TD ON TD.IdTipoDomicilio = D.IdTipoDomicilio
	LEFT JOIN [dbo].[PV_PaisRepublica] AS PR ON D.IdPais= PR.id
	LEFT JOIN [dbo].[S_Proveedor] AS P ON P.IdProveedor = D.IdProveedor 
	WHERE P.IdProveedor = @IdProveedor AND D.Activo = 1 ORDER BY D.IdTipoDomicilio 	

END
