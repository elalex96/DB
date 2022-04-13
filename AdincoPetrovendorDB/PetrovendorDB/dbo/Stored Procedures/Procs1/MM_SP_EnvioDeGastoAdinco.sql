USE Petrovendor
GO
DROP PROCEDURE IF EXISTS MM_SP_EnvioDeGastoAdinco
GO-- =============================================  
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
-- Author:		<Luis David>
-- UPDATED at: <11/04/2022>
-- Description:	<Clasificación gasto en mes presentación corriente Amatitlán (Issue#1730)>
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
	DECLARE @RFC VARCHAR(300) = (SELECT TOP 1 CTA.RFC FROM Adinco..CO_CONTRATO AS CTO
									JOIN ADINCO..CO_CONTRATISTA AS CTA
										ON CTO.IDCONTRATISTA = CTA.IDCONTRATISTA 
									JOIN FI_FACTURA AS F
										ON CTO.IDCONTRATO = F.IDCONTRATO
									WHERE F.IDFACTURA = @idFacturaP);
	DECLARE @IdCatalogoCuentasSH INT = (SELECT TOP 1 LTRIM(IdCatalogoCuentasSH) 
						FROM Adinco..CO_CatalogoCuentaSH CC
						JOIN Adinco..CO_VersionCatalogoCuentasSH VCC 
						ON CC.IdVersion = VCC.IdVersion
						WHERE vcc.IdVersion = 10002
						and Nivel3 like '5003.001.000')
	DECLARE @Tabla TABLE (Id INT IDENTITY, idRegistro INT);
    ---ESTATUS DE APROBACION DE LA FACTURA
	
    SELECT TOP 1
           @EstatusAprobacionFactura = TA.IdEstatusOperacion
    FROM dbo.MM_AceptacionFactura AS AF
        LEFT JOIN dbo.TA_Operacion AS TA
            ON TA.IdDocumento = AF.IdAceptacionFactura
               AND TA.IdTipoOperacion = 10
    WHERE AF.IdFactura = @idFacturaP
    ORDER BY AF.CreadoEl DESC

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
			--SE COMPARA EL RFC(AMATITLÁN) PARA CLASIFICAR SU GASTO EN EL MES PRESENTACIÓN CORRIENTE
			IF @RFC = 'PAM140722DK6'
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
					   CASE WHEN DAY(f.FechaTimbrado) > 20
								THEN DATEADD(MONTH,1,f.FechaTimbrado)
							WHEN DAY(f.FechaTimbrado) > 20 AND MONTH(f.FechaTimbrado) = 12
								THEN DATEADD(YEAR,1,(DATEADD(month, 1, f.FechaTimbrado)))
							WHEN DAY(f.FechaTimbrado) <= 20 AND MONTH(f.FechaTimbrado) <= 12
								THEN f.FechaTimbrado
						END AS MesPresentacion,
					   10004,
					   @IdUsuario,
					   GETDATE(),
					   pr.IdInstalacion,
					   pr.IdCatalogoCuentasSH,
					   1,
					   1,
					   pr.CostosAtribuiblesAdministracion,
					   0,
					   pr.IdGastoRubro,
					   @IdCatalogoCuentasSH,
					   pr.IdAceptacionPedidoDetalle
				FROM Petrovendor.dbo.CO_Registro pr
				JOIN FI_Factura f 
					ON pr.IdFactura = f.IdFactura
				WHERE pr.IdRegistro = @IdRegistro;
				SELECT @IdRegistroAdinco = SCOPE_IDENTITY();
				INSERT INTO dbo.CO_RelacionRegistroAdinco (IdRegistroPetrovendor, IdRegistroAdinco)
				VALUES
				(   @IdRegistro,      -- IdRegistroPetrovendor - int  
					@IdRegistroAdinco -- IdRegistroAdinco - int  
				);
			END
			ELSE
			BEGIN -- SI NO ES AMATITLAN SIGUE SU CURSO NORMAL
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

END
