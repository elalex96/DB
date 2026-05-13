-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 19-06-17
-- Description:	  
-- =============================================
CREATE PROCEDURE [dbo].[SP_DG_ConsultarDomicilios] 
	-- Add the parameters for the stored procedure here
	@IdProveedor int
	 

	---@Comentario NVARCHAR(MAX)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	

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
	WHERE P.IdProveedor = @IdProveedor AND D.IdTipoDomicilio <> 1 AND D.Activo = 1

END


