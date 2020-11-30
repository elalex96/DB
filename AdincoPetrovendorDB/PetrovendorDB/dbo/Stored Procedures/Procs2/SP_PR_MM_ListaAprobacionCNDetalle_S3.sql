-- =============================================
-- Author:      DANIEL Cruz
-- Create date: 08-02-18
-- Description: Consultar detalle de encabezado de aprobación de carta de contenido nacional en procura 
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_MM_ListaAprobacionCNDetalle_S3]
    -- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdAceptacionCartaPCN INT,
@IdUsuario INT
AS
     BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
         SET NOCOUNT ON;
    -- Insert statements for procedure here
    DECLARE @USUARIOAPROBADORCN INT = (SELECT  
                                            ISNULL(UR.S_RolUsuario,0)
                                        FROM S_Usuario AS U
                                        LEFT JOIN dbo.S_UsuarioRol AS UR ON UR.IdUsuario = U.IdUsuario
                                        WHERE U.IdUsuario = @IdUsuario AND 
                                            UR.IdRol = 3 AND 
                                            U.Activo = 1 AND 
                                            U.IsEliminado = 0 AND 
                                            UR.Activo = 1)

        SELECT '' AS Documento,--0
             AC.IdAceptacionCartaPCN,--1
             Ac.IdAceptacionPedido, --2
             AP.IdPedido, --3
             AC.IdDocumento, --4
             Ac.CreadoEl,--5
            CONCAT(PR.RazonSocial ,' ', PR.RegimenCapital) AS Proveedor, --6
            TD.TipoValidacion, --7
            TD.IdTipoValidacionDoc, --8
            ISNULL(AC.ComentarioEvaluador, '') AS ComentarioEvaluador, --9
            ISNULL(AC.FechaEvaluacion, '') AS FechaEvaluacion, --10
            ISNULL(U.Nombre, '') AS Nombre,--11
            ISNULL(AC.ComentarioProveedor,'') AS ComentarioProveedor,--12
            PG.IdPedido AS IdPedidoGeneral,--13
            TP.IdTipoPedido,--14
            D.Identificador,--15
            D.Carpeta,--16
            D.Extension,--17
            ISNULL(@USUARIOAPROBADORCN, 0) AS UsuarioAprobador,--18
            ISNULL(AC.Editado,0) AS Editado,
            ISNULL(AC.IdProceso,0) AS IdProceso
        FROM [dbo].[MM_AceptacionCartaPCN] AS AC
        INNER JOIN [dbo].[S_Documento_S3] AS D ON D.IdDocumento = AC.IdDocumento
        INNER JOIN [dbo].[MM_AceptacionPedido] AS AP ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
        INNER JOIN [dbo].[MM_Pedido] AS P ON P.IdPedido = AP.IdPedido
        INNER JOIN [dbo].[S_Proveedor] AS PR ON PR.IdProveedor = P.IdSubcontratista
        INNER JOIN [dbo].[S_TipoValidacionDoc] AS TD ON TD.IdTipoValidacionDoc = AC.IdEstatus
        INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IdProveedor
        LEFT JOIN [dbo].[S_Usuario] as U ON U.IdUsuario = AC.IdUsuarioEvaluador
        LEFT  JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
        WHERE  P.IdProveedorCompras = @IdProveedor AND IdAceptacionCartaPCN=@IdAceptacionCartaPCN

     END;