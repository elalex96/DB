CREATE PROCEDURE [dbo].[MM_SP_EnvioDeGastoCompraDirectaAdinco]
@idFacturaP INT,
@IdFacturaAdinco INT,
/*--------------------parametros contrato  --------------------*/
@IdContrato INT = NULL,
@IdUsuario INT = NULL,
@FechaRegistro DATETIME = NULL
/*-------------------------------------------------------------*/
AS
BEGIN
    DECLARE @IdRegistroAdinco INT = 0,
            @Contador INT = 1,
            @IdRegistro INT,
            @Cuenta INT,
            @XMLAdinco INT,
            @XMLPetrovendor INT,
			@EstatusAprobacionFactura INT,
			@MontoRegistro FLOAT,
			@IdUsuarioADINCO INT,
            @IdProveedorCursor AS nvarchar(400);

	SET @IdUsuarioADINCO = (SELECT IdUsuarioADINCO FROM S_Usuario WHERE IdUsuario = @IdUsuario);

	DECLARE @RFC VARCHAR(300) = (SELECT TOP 1 CTA.RFC FROM Adinco..CO_CONTRATO AS CTO
									JOIN ADINCO..CO_CONTRATISTA AS CTA
										ON CTO.IDCONTRATISTA = CTA.IDCONTRATISTA 
									JOIN FI_FACTURA AS F
										ON CTO.IDCONTRATO = F.IDCONTRATO
									WHERE F.IDFACTURA = @idFacturaP);


            CREATE TABLE #RegistroTemp
            (
            id int primary key not null identity(1,1),
            IdPrograma int,
            IdFactura int,
            MontoRegistro decimal,
            InicioEjecucion date,
            FinEjecucion date,
            Comentarios varchar(max),
            MesPresentacion date,
            IdEstado int,
            IdUsuarioCreadoPor int,
            FecMovto datetime,
            IdInstalacion int,
            IdCatalogoCuentasSH int,
            Poliza varchar(max),
            IsEditable bit,
            CostosAtribuiblesAdministracion bit,
            PCN float,
            IdGastoRubro int,
            IdCBSISH int,
            IdAceptacionPedidoDetalle int,
            IdRegistro int
            )

			-- SE VALIDA LA CANTIDAD DE CONCEPTOS
			IF exists (SELECT 1         -- CUANDO TIENE CONCEPTOS
			FROM dbo.CN_CompraDirecta AS CNCD
			LEFT JOIN dbo.MM_BS_Actividad AS BS ON BS.IdActividad = CNCD.IdActividadBS
			LEFT JOIN dbo.CN_ClasificacionContenidoSH AS SH ON SH.IdClasificacionSH = CNCD.IdCDCN
			join FI_Factura f on cncd.IdFactura = f.IdFactura
			WHERE
			F.IdFactura = @idFacturaP)
			BEGIN
				--------------------------------
				-------- se inserta en la tabla temporal
				---------------------------------
				INSERT INTO #RegistroTemp
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
					IdAceptacionPedidoDetalle,
					IdRegistro
				)SELECT pr.IdLineaPresupuestoMes,
					   @IdFacturaAdinco,
					   CNCD.ValorFactura as MontoRegistro,
					   pr.InicioEjecucion,
					   pr.FinEjecucion,
					   CNCD.DescripcionBienesServicios as Comentarios,
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
					   pr.IdAceptacionPedidoDetalle,
					   pr.IdRegistro
				FROM dbo.CN_CompraDirecta AS CNCD
				LEFT JOIN dbo.MM_BS_Actividad AS BS     ON BS.IdActividad = CNCD.IdActividadBS
				LEFT JOIN dbo.CN_ClasificacionContenidoSH AS SH   ON SH.IdClasificacionSH = CNCD.IdCDCN
				join FI_Factura f on cncd.IdFactura = f.IdFactura
				join dbo.CO_Registro as pr on cncd.IdFactura = pr.IdFactura
				WHERE   
				--CNCD.IdPedido = 12565 
				--and
				CNCD.IdFactura in (@idFacturaP)
				SELECT @Cuenta = COUNT(1)
				FROM #RegistroTemp;
				WHILE (@Contador <= @Cuenta)
				BEGIN
				IF (ISNULL(@IdRegistroAdinco, 0) = 0)
				BEGIN
				---- se obtiene el idregistro
				SELECT @IdRegistro = idRegistro
				FROM #RegistroTemp
				WHERE Id = @Contador;
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
				)SELECT 
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
				FROM #RegistroTemp
				WHERE id = @Contador
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
												   'PASE DE GASTO - ENVIO POR MM_SP_EnvioDeGastoCompraDirectaAdinco', -- nvarchar(max)  
												   '',                                                   -- nvarchar(50)  
												   0;
					SET @IdRegistroAdinco = NULL;
					SET @Contador += 1;
				END
			END
			else -- CUANDO NO TIENE CONCEPTOS
			begin
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

			SET @MontoRegistro = (SELECT TOP 1 MontoRegistro FROM Adinco.dbo.CO_Registro WHERE IdRegistro = @IdRegistroAdinco);

			IF @RFC = 'PAM140722DK6'
			BEGIN

				INSERT INTO Adinco..CO_RegistroMarkup(
					GastoId,
					Porcentaje,
					MontoEquivalente,
					MontoGasto,
					Activo,
					CreadoPor,
					CreadoEn,
					ContratoId
				)
				VALUES
				(
					@IdRegistroAdinco,
					0,
					0,
					@MontoRegistro,
					1,
					ISNULL(@IdUsuarioADINCO,1),
					GETDATE(),
					10007--CONTRATO AMATITLAN;
				);

			END

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
			end
END