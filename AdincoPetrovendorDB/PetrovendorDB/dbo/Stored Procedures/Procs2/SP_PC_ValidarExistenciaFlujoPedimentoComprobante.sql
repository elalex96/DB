-- =============================================
-- Author:	Daniel Cruz
-- Create date: 27-03-18
-- Description:	CONSULTAR SI EL PROVEEDOR ES EXTRANJERO Y SI YA EXISTEN FLUJOS PARA PEDIMENTOS O COMPROBANTES
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_ValidarExistenciaFlujoPedimentoComprobante]
-- Add the parameters for the stored procedure here
@IdProveedor INT, 
@IdPedido    INT, 
@IdContrato  INT
AS
    BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;

        -- Insert statements for procedure here
        DECLARE @EXISTE_FLUJO_ACTIVO_PREDETERMINADO INT= 0;
        DECLARE @EXISTE_FLUJO NVARCHAR(50);
        DECLARE @Nacionalidad INT;
        DECLARE @NOMBRE_PROVEEDOR NVARCHAR(MAX)= '';
        DECLARE @EXISTE_FLUJO_DEA INT= 0;
        DECLARE @ISDEA BIT;
        ---Validación de Estatus de documentos

        SELECT @Nacionalidad = S.IdNacionalidad
        FROM dbo.MM_Pedido P
             INNER JOIN dbo.S_Proveedor S ON S.IdProveedor = P.IdSubcontratista
        WHERE P.IdPedido = @IdPedido
              AND P.IdProveedorCompras = @IdProveedor;
        IF @Nacionalidad = 2

        /*NACIONALIDA EXTRANJERA*/

            BEGIN
                IF EXISTS -- se valida si el proveedor es de DEA
                (
                    SELECT 1
                    FROM dbo.DEA_Proveedor
                    WHERE IdProveedor = @IdProveedor
                )
                    BEGIN
                        SET @ISDEA = 1;
                        SET @EXISTE_FLUJO_DEA =
                        (
                            SELECT COUNT(RCFA.IdFlujoComprobante)
                            FROM dbo.MM_SolicitudPedido SP
                                 LEFT JOIN dbo.MM_Pedido P ON P.IdSolicitudPedido = SP.IdSolicitudPedido
                                 LEFT JOIN dbo.MM_AceptacionPedido AP ON AP.IdPedido = P.IdPedido
                                 LEFT JOIN dbo.MM_SolicitudPedidoDetalle SPD ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido
                                 LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPDL ON SPDL.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
                                 LEFT JOIN dbo.RelacionCentroCostoFlujoAprob RCFA ON RCFA.IdCentroCosto = SPDL.IdCentroCosto
                            WHERE P.IdPedido = @IdPedido
                                  AND RCFA.IdFlujoComprobante IS NOT NULL
                            GROUP BY RCFA.IdFlujoComprobante, 
                                     RCFA.IdCentroCosto
                        );
                        IF ISNULL(@EXISTE_FLUJO_DEA, 0) = 0
                            BEGIN
                                SET @EXISTE_FLUJO = 'CREAR_FLUJO';
                                SELECT @NOMBRE_PROVEEDOR = (ISNULL(S.RazonSocial, '') + ' ' + ISNULL(R.Regimen, ''))
                                FROM dbo.MM_Pedido P
                                     INNER JOIN dbo.S_Proveedor S ON S.IdProveedor = P.IdSubcontratista
                                     LEFT JOIN dbo.RegimenCapital AS R ON R.IdRegimenCapital = S.IdTipoRegimen
                                WHERE P.IdPedido = @IdPedido
                                      AND P.IdProveedorCompras = @IdProveedor;
                        END;
                            ELSE
                            SET @EXISTE_FLUJO = 'EXISTE_FLUJO';
                END;
                    ELSE
                    BEGIN
                        SET @ISDEA = 0;
                        SET @EXISTE_FLUJO_ACTIVO_PREDETERMINADO =
                        (
                            SELECT COUNT(F.IdFlujoTarea)
                            FROM dbo.TA_FlujoTarea F
                            WHERE F.IdProveedor = @IdProveedor
                                  AND F.Activo = 1
                                  AND ISNULL(F.Eliminado, 0) = 0
                                  AND F.Predeterminado = 1
                                  AND F.IdTipoOperacion = 16
                        );

                        /*FLUJO DE PEDIMENTO O COMPROBANTE EXTRANJERO*/

                        IF @EXISTE_FLUJO_ACTIVO_PREDETERMINADO = 0
                            BEGIN
                                SET @EXISTE_FLUJO = 'CREAR_FLUJO';
                                SELECT @NOMBRE_PROVEEDOR = (ISNULL(S.RazonSocial, '') + ' ' + ISNULL(R.Regimen, ''))
                                FROM dbo.MM_Pedido P
                                     INNER JOIN dbo.S_Proveedor S ON S.IdProveedor = P.IdSubcontratista
                                     LEFT JOIN dbo.RegimenCapital AS R ON R.IdRegimenCapital = S.IdTipoRegimen
                                WHERE P.IdPedido = @IdPedido
                                      AND P.IdProveedorCompras = @IdProveedor;
                        END;
                            ELSE
                            SET @EXISTE_FLUJO = 'EXISTE_FLUJO';
                END;
                SELECT CASE
                           WHEN @ISDEA = 1
                           THEN 'DEA'
                           ELSE 'EXTRANJERO'
                       END, 
                       @EXISTE_FLUJO, 
                       ISNULL(@NOMBRE_PROVEEDOR, '');
        END;
            ELSE
            BEGIN
                SELECT 'NACIONAL', 
                       '', 
                       '';
        END;
    END;