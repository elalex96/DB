-- =============================================  
-- Author:  <Luis David>  
-- Create date: 18/02/2021
-- Description: se valida la aprobacion de la factura para el envio de gasto  
-- =============================================  
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
			@IdProveedorCursor AS nvarchar(400);

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