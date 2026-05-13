use Petrovendor
go
drop proc if exists SP_TA_ConsultarDetalleFlujoTarea
go
-- =============================================
-- Author:		Daniel AC
-- Create date: 29-03-17
-- Description:	Regresa la información de una Tarea Flujo 				
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 10-01-2018
-- Description:	Regresa la información de una Tarea Flujo + Parametros de orden de compra IdPedido				
-- =============================================
-- Author:		David
-- Create date: marzo 31 24
-- Description:	Se optimiza sp Issue #2686 petrovendor
-- =============================================
-- Author:		David
-- Create date: marzo 31 24
-- Description:	Se optimiza sp Issue #2686 petrovendor
-- =============================================
	CREATE PROCEDURE [dbo].[SP_TA_ConsultarDetalleFlujoTarea] 
    @IdOperacion int 
AS
BEGIN
    SET NOCOUNT ON;

    SELECT  
        FT.Nombre,
        TAE.Nombre AS EstadoOperacion, 
        TOO.IdEstadoFlujo, 
        TFT.Nombre AS TipoFlujo,
        EFT.NombreEstado,
        TOO.IdAsignador,
        U.Nombre AS [Nombre Asignador], 
        TOO.FechaRegistro, 
        TOO.Descripcion, 
        TP.Nombre, 
        TV.DiaVencimiento, 
        TOO.IdEstatusOperacion, 
        U.Correo AS [Correo Asignador], 
        TCC.Descripcion, 
        TTO.NombreOperacion, 
        TOO.IdDocumento,
        TOO.IdTipoOperacion, 
        ISNULL(PS.IdPedido, 0) AS IdPedido
    FROM 
        TA_Operacion AS TOO (NOLOCK)
    INNER JOIN 
        TA_TipoOperacion AS TTO (NOLOCK) ON TOO.IdTipoOperacion = TTO.IdTipoOperacion
    INNER JOIN 
        S_Usuario AS U (NOLOCK) ON TOO.IdAsignador = U.IdUsuario
    INNER JOIN 
        TA_Prioridad AS TP (NOLOCK) ON TOO.IdPrioridad = TP.IdPrioridad
    INNER JOIN 
        TA_Vencimiento AS TV (NOLOCK) ON TOO.IdVigencia = TV.IdVencimiento
    INNER JOIN 
        TA_FlujoTarea AS FT (NOLOCK) ON TOO.IdFlujoTarea = FT.IdFlujoTarea
    INNER JOIN 
        TA_TipoFlujoTarea AS TFT (NOLOCK) ON FT.IdTipoFlujo = TFT.IdTipoFlujoTarea
    INNER JOIN 
        TA_EstadoFlujoTarea AS EFT (NOLOCK) ON EFT.IdEstado = TOO.IdEstadoFlujo
    INNER JOIN 
        TA_Estatus AS TAE (NOLOCK) ON TAE.IdEstatus = TOO.IdEstatusOperacion
    LEFT JOIN 
        TA_ComentariosTareaCancelada AS TCC (NOLOCK) ON TOO.IdOperacion = TCC.IdOperacion
    LEFT JOIN 
        dbo.MM_Pedidos AS PS (NOLOCK) ON TOO.IdDocumento  = PS.IdIdentificador
                                            AND TOO.IdProveedor = PS.IdProveedorCliente 
                                            AND PS.IdTipoPedido = 1 -- ORDEN DE COMPRA DIRECTA 
    WHERE  
        TOO.IdOperacion = @IdOperacion;
END
