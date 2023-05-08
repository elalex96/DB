-- =============================================
-- Author:		Pedro Acuña
-- Create date: 22-08-2019
-- Description:	Cambia y valida que el contrato pertenezca a la empresa
-- =============================================

CREATE PROCEDURE sp_CambioContratoLineas
    @IdSolicitudPedido INT,
    @IdContrato INT
AS
BEGIN
    DECLARE @IdProveedor INT,
            @IdContratoOld INT

    SELECT @IdProveedor = sp.IdProveedor,
           @IdContratoOld = sp.IdContrato
    FROM dbo.MM_SolicitudPedido sp
    WHERE sp.IdSolicitudPedido = @IdSolicitudPedido

    IF (ISNULL(@IdContratoOld, 0) <> @IdContrato)
    BEGIN
        -- si el contrato le pertenece a la operadora entonces se puede hacer el cambio
        IF EXISTS
        (
            SELECT DISTINCT
                   CO_Contrato.IdContrato
            FROM Adinco.dbo.AP_PerfilUsuario AS PU
                INNER JOIN Adinco.dbo.AP_Perfil
                    ON PU.PerfilID = AP_Perfil.IdPerfil
                INNER JOIN Adinco.dbo.AP_Rol
                    ON AP_Perfil.IdRol = AP_Rol.IdRol
                INNER JOIN Adinco.dbo.CO_Contrato
                    ON AP_Perfil.IdContrato = CO_Contrato.IdContrato
                INNER JOIN Adinco.dbo.CO_AreaContractual
                    ON CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual
                INNER JOIN Petrovendor.dbo.S_UsuarioProveedor uProv
                    ON CO_Contrato.IdContrato = uProv.IdContrato
                INNER JOIN Petrovendor.dbo.S_Proveedor prov
                    ON uProv.IdProveedor = prov.IdProveedor
                INNER JOIN Adinco.dbo.CO_PeriodoContrato per
                    ON per.IdContrato = CO_Contrato.IdContrato
            WHERE ISNULL(prov.IsEliminado, 0) = 0
                  AND prov.IdProveedor = ISNULL(@IdProveedor, 0)
                  AND CO_Contrato.IdContrato = @IdContrato
        )
        BEGIN
            INSERT INTO dbo.HistoricoCambioContrato
            (
                IdSolicitudPedido,
                IdContratoOld,
                FechaModificado
            )
            SELECT IdSolicitudPedido,
                   IdContrato,
                   GETDATE()
            FROM dbo.MM_SolicitudPedido
            WHERE IdSolicitudPedido = @IdSolicitudPedido

            UPDATE dbo.MM_SolicitudPedido
            SET IdContrato = @IdContrato
            WHERE IdSolicitudPedido = @IdSolicitudPedido

            UPDATE dbo.MM_Pedido
            SET IdContrato = @IdContrato
            WHERE IdSolicitudPedido = @IdSolicitudPedido

            UPDATE f
            SET f.IdContrato = @IdContrato
            FROM dbo.FI_Factura f
                INNER JOIN dbo.MM_AceptacionFactura af
                    ON af.IdFactura = f.IdFactura
                INNER JOIN dbo.MM_AceptacionPedido ap
                    ON ap.IdAceptacionPedido = af.IdAceptacionPedido
                INNER JOIN dbo.MM_Pedido p
                    ON p.IdPedido = ap.IdPedido
            WHERE p.IdSolicitudPedido = @IdSolicitudPedido

            UPDATE axml
            SET axml.IdContrato = @IdContrato
            FROM dbo.FI_Factura f
                INNER JOIN dbo.MM_AceptacionFactura af
                    ON af.IdFactura = f.IdFactura
                INNER JOIN dbo.MM_AceptacionPedido ap
                    ON ap.IdAceptacionPedido = af.IdAceptacionPedido
                INNER JOIN dbo.MM_Pedido p
                    ON p.IdPedido = ap.IdPedido
                INNER JOIN dbo.FI_ArchivoXml axml
                    ON axml.IdFactura = f.IdFactura
            WHERE p.IdSolicitudPedido = @IdSolicitudPedido

            UPDATE pc
            SET pc.IdContrato = @IdContrato
            FROM dbo.FI_Factura f
                INNER JOIN dbo.MM_AceptacionFactura af
                    ON af.IdFactura = f.IdFactura
                INNER JOIN dbo.MM_AceptacionPedido ap
                    ON ap.IdAceptacionPedido = af.IdAceptacionPedido
                INNER JOIN dbo.MM_Pedido p
                    ON p.IdPedido = ap.IdPedido
                INNER JOIN dbo.FI_ArchivoXml axml
                    ON axml.IdFactura = f.IdFactura
                INNER JOIN dbo.MM_Pedidos ps
                    ON ps.IdIdentificador = p.IdPedido
                       AND p.IdProveedorCompras = ps.IdProveedorCliente
                INNER JOIN dbo.FI_PedimentoComprobante pc
                    ON pc.IdPedidoGeneral = ps.IdPedido
            WHERE p.IdSolicitudPedido = @IdSolicitudPedido

            SELECT 1 -- El contrato pertenece a la operadora
        END
        ELSE
        BEGIN
            SELECT 0 -- el Contrato no pertenece a la operadora
        END
    END
	ELSE
    BEGIN
		SELECT 1 -- Como el contrato es igual entonces devuelvo verdadero para que continue con el proceso
	END	


END

