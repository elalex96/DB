CREATE  PROCEDURE [dbo].[SP_Ax_WsCarso_ValidarNoExistaCotizaciones]
    -- Add the parameters for the stored procedure here
    @DataAreaID NVARCHAR(500),
	@IdComparativa NVARCHAR(500)

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	

	DECLARE @ID_REQUISICION INT 


	SELECT  @ID_REQUISICION = IdSolicitudPedido
	FROM dbo.AX_Comparativa
	WHERE DataAreaId=@DataAreaID
	AND IdComparativa=@IdComparativa
	GROUP BY IdSolicitudPedido

	SELECT COUNT(1)
	FROM dbo.MM_PeticionOferta
	WHERE IdSolicitudPedido=@ID_REQUISICION
	AND ISNULL(IdEliminado,0)=0



END;
