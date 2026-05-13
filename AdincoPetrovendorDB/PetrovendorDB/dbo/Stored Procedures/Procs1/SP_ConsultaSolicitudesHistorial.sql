-- =============================================
-- Author:		Alexander E
-- Create date: 05/06/2018
-- Description:	Consultar solicitudes de pedido par visualizar el historial
-- Author:		Daniel AC
-- Create date:  05/06/2018
-- Description:	Descartar solicitudes de pedido con estatus eliminado
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultaSolicitudesHistorial] 
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
    @IdContrato    INT = NULL,
    @IdUsuario     INT = NULL,
    @FechaRegistro DATETIME = NULL
 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	CREATE TABLE #temsolpedpeds(
		IdVisible INT NULL,
		IdInvisible INT NULL,
		FechaAlta DATETIME NULL,
		TipoSol NVARCHAR(MAX),
		Span NVARCHAR(MAX),
		Proveedor NVARCHAR(MAX),
		Motivo NVARCHAR(MAX)
	)

	INSERT INTO #temsolpedpeds(IdVisible,IdInvisible,FechaAlta,TipoSol,Span,Proveedor, Motivo)
	SELECT IdSolicitudPedido,IdSolicitudPedido, FechaAlta, 'Requisición', 'label label-important','N/A',MotivoUrgencia 
	FROM dbo.MM_SolicitudPedido WHERE IdProveedor = @IdProveedor AND ISNULL(IdEstatusEliminado,0) <> 1

	INSERT INTO #temsolpedpeds(IdVisible,IdInvisible,FechaAlta,TipoSol,Span, Proveedor,Motivo)
	SELECT PD.IdPedido,PO.IdSolicitudPedido, PD.CreadorEl, 'Pedido', 'label label-primary', PR.RazonSocial,SP.MotivoUrgencia
	FROM MM_Pedido AS PO
	LEFT JOIN dbo.MM_Pedidos AS PD ON PD.IdIdentificador = PO.IdPedido AND PO.IdProveedorCompras = PD.IdProveedorCliente AND PD.IdTipoPedido in (2, 6)
	LEFT JOIN dbo.s_proveedor AS PR ON PO.IdSubcontratista = PR.IdProveedor
	LEFT JOIN dbo.MM_SolicitudPedido SP ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
	WHERE PO.IdProveedorCompras = @IdProveedor AND  ISNULL(PO.IdEstatusEliminado,0) <> 1

	SELECT * FROM #temsolpedpeds ORDER BY FechaAlta DESC

END
