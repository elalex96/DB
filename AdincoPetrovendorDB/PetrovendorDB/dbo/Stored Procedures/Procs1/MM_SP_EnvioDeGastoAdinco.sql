-- =============================================  
-- Author:  <DANIEL AC>  
-- Create date: 01/10/2019  
-- Description: Se  removio insertado de XML en Adinco   
-- =============================================  
-- Author:  <Alexander Gomez>  
-- Create date: 28/10/2019  
-- Description: se agrego la bitacora de pase adinco  
-- =============================================  
-- Author:  <Alexander Gomez>  
-- Create date: 07/04/2020
-- Description: se valida la aprobacion de la factura para el envio de gasto  
-- =============================================  
CREATE PROCEDURE [dbo].[MM_SP_EnvioDeGastoAdinco]
@idFacturaP INT,
@IdFacturaAdinco INT,
/*--------------------parametros contrato  --------------------*/
@IdContrato INT = NULL,
@IdUsuario INT = NULL,
@FechaRegistro DATETIME = NULL
/*-------------------------------------------------------------*/

AS
BEGIN
    DECLARE @IdRegistroAdinco INT,
            @Contador INT = 1,
            @IdRegistro INT,
            @Cuenta INT,
            @XMLAdinco INT,
            @XMLPetrovendor INT,
            @EstatusAprobacionFactura INT;
    ---ESTATUS DE APROBACION DE LA FACTURA

    SELECT TOP 1
           @EstatusAprobacionFactura = TA.IdEstatusOperacion
    FROM dbo.MM_AceptacionFactura AS AF
        LEFT JOIN dbo.TA_Operacion AS TA
            ON TA.IdDocumento = AF.IdAceptacionFactura
               AND TA.IdTipoOperacion = 10
    WHERE AF.IdFactura = @idFacturaP
    ORDER BY AF.CreadoEl DESC

    DECLARE @Tabla TABLE (Id INT IDENTITY, idRegistro INT);

    INSERT INTO @Tabla (idRegistro)
    SELECT pr.IdRegistro
    FROM Petrovendor.dbo.CO_Registro pr
    WHERE pr.IdFactura = @idFacturaP;

    SELECT @Cuenta = COUNT(1)
    FROM @Tabla;

    --SE VALIDA EL ESTATUS DE LA FACTURA
    --****SE COMENTA ESTE CODIGO YA QUE CUANDO SE EJECUTA ESTE SP AUN NO SE CAMBIA EL ESTATUS DE LA OPERACION *** 
    --IF @EstatusAprobacionFactura = 2 --APROBADA
    --BEGIN

    --Se copian todos los registros de gastos con los que cuenta esta factura  
    WHILE (@Contador <= @Cuenta)
    BEGIN
        SELECT @IdRegistro = idRegistro
        FROM @Tabla
        WHERE Id = @Contador;

        --VALIDACION DE VERIFICACION DE EXISTENCIA DE GASTO POR ACEPTACION DE PEDIDO DETALLE
        SELECT @IdRegistroAdinco = ar.IdRegistro
        FROM Adinco.dbo.CO_Registro ar
            INNER JOIN dbo.CO_Registro r
                ON r.IdAceptacionPedidoDetalle = ar.IdAceptacionPedidoDetalle
        WHERE r.IdRegistro = @IdRegistro

        IF (ISNULL(@IdRegistroAdinco, 0) = 0)
        BEGIN

            INSERT INTO Adinco.dbo.CO_Registro
            (
                IdPrograma,
                IdFactura,
                MontoRegistro,
                InicioEjecucion,
                FinEjecucion,
                Comentarios,
                MesPresentacion,
                IdEstado,
                IdUsuarioCreadoPor,
                FecMovto,
                IdInstalacion,
                IdCatalogoCuentasSH,
                Poliza,
                IsEditable,
                CostosAtribuiblesAdministracion,
                PCN,
                IdGastoRubro,
                IdCBSISH,
                IdAceptacionPedidoDetalle
            )
            SELECT pr.IdLineaPresupuestoMes,
                   @IdFacturaAdinco,
                   pr.MontoRegistro,
                   pr.InicioEjecucion,
                   pr.FinEjecucion,
                   pr.Comentarios,
                   pr.MesPresentacion,
                   10004,
                   @IdUsuario,
                   GETDATE(),
                   pr.IdInstalacion,
                   pr.IdCatalogoCuentasSH,
                   pr.Poliza,
                   1,
                   pr.CostosAtribuiblesAdministracion,
                   SUBSTRING(CAST(pr.PCN AS NVARCHAR(50)), 1, 5),
                   pr.IdGastoRubro,
                   pr.IdCBSISH,
                   pr.IdAceptacionPedidoDetalle
            FROM Petrovendor.dbo.CO_Registro pr
            WHERE pr.IdRegistro = @IdRegistro;

            SELECT @IdRegistroAdinco = SCOPE_IDENTITY();

            INSERT INTO dbo.CO_RelacionRegistroAdinco (IdRegistroPetrovendor, IdRegistroAdinco)
            VALUES
            (   @IdRegistro,      -- IdRegistroPetrovendor - int  
                @IdRegistroAdinco -- IdRegistroAdinco - int  
            );

        END

        EXEC dbo.SP_WA_InserRegistroPaseAdinco @IdRegistro,                                          -- int  
                                               2,                                                    -- int  
                                               @IdRegistroAdinco,                                    -- int  
                                               @IdUsuario,                                           -- int  
                                               0,                                                    -- int  
                                               @IdContrato,                                          -- int  
                                               'PASE DE GASTO - ENVIO POR MM_SP_EnvioDeGastoAdinco', -- nvarchar(max)  
                                               '',                                                   -- nvarchar(50)  
                                               0;

        SET @IdRegistroAdinco = NULL;
        SET @Contador += 1;

    END;
-- END;

END;
