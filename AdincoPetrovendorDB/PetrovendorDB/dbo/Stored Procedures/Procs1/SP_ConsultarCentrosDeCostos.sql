
-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <19/11/19>
-- Description:	<Se agregaron los ids del flujo de factura y comprobante>
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 28/11/2019
-- Description:	Se agregaron las notificaciones al usuarios Carga PR y Relacione PO - Pedido
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarCentrosDeCostos] @IdProveedor INT
AS
    BEGIN
        SET NOCOUNT ON;
        CREATE TABLE #CentroCosto
        (IdCentroCosto      INT, 
         numero             NVARCHAR(MAX), 
         CentroCosto        NVARCHAR(MAX), 
         CreadoPor          INT, 
         IsActivo           BIT, 
         IdFlujo            INT, 
         IdFlujoFactura     INT, 
         IdFlujoComprobante INT
        );
        INSERT INTO #CentroCosto
               SELECT c.IdCentroCosto, 
                      numero, 
                      c.CentroCosto, 
                      CreadoPor, 
                      IsActivo, 
                      rel.IdFlujo, 
                      FF.IdFlujoTarea AS IdFlujoFactura, 
                      FC.IdFlujoTarea AS IdFlujoComprobante
               FROM [dbo].[CC_CentroCosto] c
                    LEFT JOIN dbo.RelacionCentroCostoFlujoAprob rel ON rel.IdCentroCosto = c.IdCentroCosto
                    LEFT JOIN dbo.TA_FlujoTarea FF ON FF.IdFlujoTarea = REL.IdFlujoFactura
                                                      AND FF.Activo = 1
                    LEFT JOIN dbo.TA_FlujoTarea FC ON FC.IdFlujoTarea = REL.IdFlujoComprobante
                                                      AND FC.Activo = 1
               WHERE C.IdProveedor = @IdProveedor
                     AND IsActivo = 1;
        SELECT IdCentroCosto, 
               numero, 
               CentroCosto, 
               CreadoPor, 
               IsActivo, 
               IdFlujo, 
               IdFlujoFactura, 
               IdFlujoComprobante, 
               dbo.Fn_ObtenerUsuariosNotificarDEACC(IdCentroCosto, 'NOT_CARGA_PR') AS UsuariosNotPR, 
               dbo.Fn_ObtenerUsuariosNotificarDEACC(IdCentroCosto, 'SOLITAR_RELACION_PRPO') AS UsuariosNotPOPedido
        FROM #CentroCosto
        ORDER BY CentroCosto ASC;
    END;