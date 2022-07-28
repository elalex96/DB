USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[MM_SP_EnvioDeGastoAdinco]    Script Date: 28/07/2022 04:06:10 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
-- Author:		<Luis David>
-- Create date: <15/06/2022>
-- Description:	<Se valida si la factura es de Murphy para así agregar la linea presupuesto 241612 (Issue #1865 Petrovendor)>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <28/07/2022>
-- Description:	<Se agrega la cuenta de sector de hidrocarburos para amatitlan (Issue#1954)>
-- =============================================
ALTER PROCEDURE [dbo].[MM_SP_EnvioDeGastoAdinco]
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
            @EstatusAprobacionFactura INT,
			@IdCatalogoCuentasSH_Amatitlan INT;

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
                ON ar.IdAceptacionPedidoDetalle = r.IdAceptacionPedidoDetalle
        WHERE r.IdRegistro = @IdRegistro

        IF (ISNULL(@IdRegistroAdinco, 0) = 0)
        BEGIN
			--SE COMPARA EL RFC(AMATITLÁN) PARA CLASIFICAR SU GASTO EN EL MES PRESENTACIÓN CORRIENTE
			IF @RFC = 'PAM140722DK6'
			BEGIN

				SET @IdCatalogoCuentasSH_Amatitlan = (SELECT TOP 1
															IdCatalogoCuentasSH
														FROM Adinco..CO_CatalogoCuentaSH AS CCH
															JOIN Adinco..CO_VersionCatalogoCuentasSH AS VCCH
																ON CCH.IdVersion = VCCH.IdVersion
														WHERE VCCH.Activo = 1	
															AND CCH.Descripcion = 'Gastos pre operativos' 
															AND CCH.Nivel2 = '1302.001');

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
					   CASE WHEN DAY(f.FechaTimbrado) > 20 AND MONTH(f.FechaTimbrado) = 12
								THEN DATEFROMPARTS ( YEAR(DATEADD(YEAR,1,f.FechaTimbrado)), MONTH(DATEADD(MONTH,1,f.FechaTimbrado)), 01 )
							WHEN DAY(f.FechaTimbrado) <= 20 AND MONTH(f.FechaTimbrado) <= 12
								THEN DATEFROMPARTS ( YEAR(f.FechaTimbrado), MONTH(f.FechaTimbrado), 01 )
							WHEN DAY(f.FechaTimbrado) > 20
								THEN DATEFROMPARTS ( YEAR(f.FechaTimbrado), MONTH(dateadd(MONTH,1,f.FechaTimbrado)), 01 )
						END AS MesPresentacion,
					   10004,
					   @IdUsuario,
					   GETDATE(),
					   pr.IdInstalacion,
					   @IdCatalogoCuentasSH_Amatitlan,
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
