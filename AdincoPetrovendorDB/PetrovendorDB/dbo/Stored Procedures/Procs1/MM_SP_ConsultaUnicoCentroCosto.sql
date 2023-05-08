-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[MM_SP_ConsultaUnicoCentroCosto]
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido INT,
	/*--------------------
    parametros contrato
  --------------------*/
    @IdContrato    INT,
    @IdUsuario     INT,
    @FechaRegistro DATETIME
  /*--------------------
  --------------------*/
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT SPDLP.IdCentroCosto
	  FROM dbo.MM_SolicitudPedidoDetalle AS SPD
	  LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS SPDLP ON SPDLP.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
	  WHERE SPD.IdSolicitudPedido = @IdSolicitudPedido
	  GROUP BY SPDLP.IdCentroCosto
END
