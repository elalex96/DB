IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'FI_RelacionaFacturaPuntoEntrega'
    )
    DROP PROCEDURE FI_RelacionaFacturaPuntoEntrega
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[FI_RelacionaFacturaPuntoEntrega]
    @idFactura       int,
    @idPuntoEntrega  int,
    @idContrato      int,
    @idUsuario       int,
    @fechaMesDiaAnio date,
    @hidrocarburo    int
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 13/04/2018
-- Description:	Relaciona Las facturas con el punto de entrega 
-- =============================================
-- 20180611	BAAC	Se modifica para ligar las comercializaciones con la factura por punto de entrega
-- =============================================	
-- 24072018	JMCD	Se modifica para ligar las comercializaciones en donde se produjo gas (condensable), las cuales son marcadas con un bit = 1 
--					en la columna EsCondensable de la tabla COM_OperacionComercializacion, que es marcado al generar las comercializaciones
--					si en la cromatografía hay volumen de n C5, I C5 Y C6+
-- =============================================	
AS
    BEGIN
        SET NOCOUNT ON

        CREATE TABLE #TipoHidrocarburo
            (
                IdTipoHidrocarburo INT,
                IdHidrocarburo     INT
            )

        DECLARE @ContProduct INT
        DECLARE @cont INT
        DECLARE @GasNoAsociado as bit
        DECLARE
            @HidrocarburoAceite INT = 1001, -- Aceite
            @HidrocarburoGas    INT = 1000; -- Gas
		DECLARE @GuardadoCorrecto INT = 1;
		DECLARE @GuardadoIncorrecto INT = 2;

        select
            @GasNoAsociado = GasNoAsociado
        from
            CO_Contrato (NOLOCK)
        where
            IdContrato = @idContrato;

        IF @hidrocarburo = @HidrocarburoGas -- Gas
            BEGIN
                INSERT INTO #TipoHidrocarburo
                    (
                        IdTipoHidrocarburo,
                        IdHidrocarburo
                    )
                VALUES
                    (
                        10002, @HidrocarburoGas
                    )
                INSERT INTO #TipoHidrocarburo
                    (
                        IdTipoHidrocarburo,
                        IdHidrocarburo
                    )
                VALUES
                    (
                        10003, @HidrocarburoGas
                    )
                INSERT INTO #TipoHidrocarburo
                    (
                        IdTipoHidrocarburo,
                        IdHidrocarburo
                    )
                VALUES
                    (
                        10004, @HidrocarburoGas
                    )
                INSERT INTO #TipoHidrocarburo
                    (
                        IdTipoHidrocarburo,
                        IdHidrocarburo
                    )
                VALUES
                    (
                        10005, @HidrocarburoGas
                    )
            END
        ELSE
            BEGIN
                IF @hidrocarburo = @HidrocarburoAceite -- Aceite
                    BEGIN
                        INSERT INTO #TipoHidrocarburo
                            (
                                IdTipoHidrocarburo,
                                IdHidrocarburo
                            )
                        VALUES
                            (
                                10000, @HidrocarburoAceite
                            )
                    END
                ELSE
                    BEGIN
                        INSERT INTO #TipoHidrocarburo
                            (
                                IdTipoHidrocarburo,
                                IdHidrocarburo
                            )
                        VALUES
                            (
                                10001, 1002
                            )
                    END
            END

        -- SE BUSCAN LAS COMERCIALIZACIONES PARA EL PUNTO DE ENTREGA PARA ASIGNARLES LA FACTURA
        SELECT
            @ContProduct = idfacturaPuntoEntrega
        FROM
            FI_FacturaPuntoEntrega (NOLOCK)
        WHERE
            productoid = @hidrocarburo
            and MesReporte = @fechaMesDiaAnio
            and PuntoEntregaid = @idPuntoEntrega

        IF (@ContProduct >= 1) --Checa si ya hay producto facturado para esa fecha y ese punto de entrega, si no hay puede entrar para insertar con la factura
            BEGIN
                SELECT
                    @GuardadoIncorrecto
            END
        ELSE
            BEGIN
                SELECT
                    @cont = idfacturaPuntoEntrega
                FROM
                    FI_FacturaPuntoEntrega FP (NOLOCK)
                    JOIN
                        FI_Factura         F (NOLOCK)
                            on FP.idFactura = f.idFactura
                WHERE
                    FP.idFactura = @idFactura
                    AND f.idContrato = @idContrato

                IF (@cont >= 1)
                    BEGIN
                        --Checa si la factura ya esta insertada a algunos datos, si ya esta insertada,modifica los datos
                        UPDATE
                            FI_FacturaPuntoEntrega
                        SET
                            PuntoEntregaId = @idPuntoEntrega,
                            ModificadoPor = @idUsuario,
                            ModificadoEl = GETDATE(),
                            ProductoId = @hidrocarburo,
                            MesReporte = @fechaMesDiaAnio
                        WHERE
                            idFactura = @idFactura
                        SELECT
                            @GuardadoCorrecto
                    END
                ELSE
                    BEGIN
                        INSERT INTO FI_FacturaPuntoEntrega
                            (
                                idFactura,
                                PuntoEntregaId,
                                ProductoId,
                                MesReporte,
                                CreadoPor,
                                CreadoEl,
                                Activo
                            )
                        VALUES
                            (
                                @idFactura, @idPuntoEntrega, @hidrocarburo, @fechaMesDiaAnio, @idUsuario, GETDATE(), 1
                            );
                        SELECT
                            @GuardadoCorrecto
                    END
            END

        -- SE LIGAN LAS FACTURAS CON LAS COMERCIALIZACIONES EN CASO DE QUE EXISTAN PARA GAS, PETROLEO Y CONDENSADO
        UPDATE
            C
        SET
            IdFactura = FP.idFactura
        FROM
            COM_OperacionComercializacion C
            JOIN
                #TipoHidrocarburo         T
                    ON C.IdTipoHidrocarburo = T.IdTipoHidrocarburo
					AND   C.IdContrato = @idContrato
					   AND C.MesReporte = @fechaMesDiaAnio
            JOIN
                FI_FacturaPuntoEntrega    FP
                    ON C.PuntoEntregaID = FP.PuntoEntregaId
                       AND C.MesReporte = FP.MesReporte
                       AND T.IdHidrocarburo = FP.ProductoId
        WHERE
            C.IdContrato = @idContrato
            AND C.MesReporte = @fechaMesDiaAnio

        -- SE LIGAN LAS FACTURAS DE CONDENSABLE
        UPDATE
            C
        SET
            IdFactura = FP.idFactura
        FROM
            COM_OperacionComercializacion C
            JOIN
                FI_FacturaPuntoEntrega    FP
                    ON C.PuntoEntregaID = FP.PuntoEntregaId
                       AND C.MesReporte = FP.MesReporte
                       AND FP.ProductoId = 1000
					   AND  C.IdContrato = @idContrato
						AND C.MesReporte = @fechaMesDiaAnio
        WHERE
            C.IdContrato = @idContrato
            AND C.MesReporte = @fechaMesDiaAnio
            AND C.IdTipoHidrocarburo = 10001
            AND C.EsCondensable = 1

    END
