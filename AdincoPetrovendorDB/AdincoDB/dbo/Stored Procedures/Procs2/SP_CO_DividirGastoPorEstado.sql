CREATE PROCEDURE [dbo].[SP_CO_DividirGastoPorEstado] 
	@IdFactura int, @IdUsuario INT, @Porcentaje decimal(18,4), @IdClvEstado int, @RegistroOriginal nvarchar(max)
    AS
	BEGIN

		CREATE TABLE #RegistroABorrar(IdRegistro INT)

		INSERT INTO #RegistroABorrar
		SELECT splitdata  
		FROM dbo.fnSplitString ( @RegistroOriginal, ',' )

		CREATE TABLE #REGISTRO_RES(IdRegistro INT, IdFactura INT, MontoRegistro DECIMAL(18, 4), CreadoPor INT, MontoRegistroPorcentaje  DECIMAL(18, 4))

		INSERT INTO #REGISTRO_RES(IdRegistro, IdFactura, MontoRegistro, CreadoPor, MontoRegistroPorcentaje)
		SELECT IdRegistro, IdFactura, MontoRegistro, CreadoPor, (MontoRegistro * @Porcentaje) / 100 FROM CO_Registro WHERE IdFactura = @IdFactura

		IF NOT EXISTS(SELECT 1 FROM RespaldoRegistro WHERE IdFactura = @IdFactura)
		BEGIN
			INSERT INTO RespaldoRegistro(IdRegistro,IdPrograma, IdFactura, MontoRegistro, InicioEjecucion, FinEjecucion, Comentarios, MesPresentacion, IdEstado, IdUsuarioCreadoPor,
								IdUsuarioModPor, FecMovto, IdInstalacion, CreadoPor, Fila, IdPedimentoComprobante, CvTipoDocFacturacion, IdCatalogoCuentasSH, Poliza,
								IsEditable, CostosAtribuiblesAdministracion, EstadoDePresentacion, MesCertificadoCIEP, IdGastoRubro, PCN, Importado, BitPCNP,
								IdCBSISH, IdAceptacionPedidoDetalle, MesGasto, ModificadoEn, CapexOpexEdicion)
			SELECT IdRegistro, R.IdPrograma, R.IdFactura, R.MontoRegistro, R.InicioEjecucion, R.FinEjecucion, R.Comentarios, MesPresentacion, IdEstado, IdUsuarioCreadoPor,
								IdUsuarioModPor, FecMovto, IdInstalacion, CreadoPor, Fila, IdPedimentoComprobante, CvTipoDocFacturacion, IdCatalogoCuentasSH, Poliza,
								IsEditable, CostosAtribuiblesAdministracion, EstadoDePresentacion, MesCertificadoCIEP, IdGastoRubro, PCN, Importado, BitPCNP,
								IdCBSISH, IdAceptacionPedidoDetalle, MesGasto, ModificadoEn, CapexOpexEdicion 
			FROM CO_Registro R 
			WHERE IdFActura = @IdFactura

			
		END

			INSERT INTO CO_Registro(IdPrograma, IdFactura, MontoRegistro, InicioEjecucion, FinEjecucion, Comentarios, MesPresentacion, IdEstado, IdUsuarioCreadoPor,
							IdUsuarioModPor, FecMovto, IdInstalacion, CreadoPor, Fila, IdPedimentoComprobante, CvTipoDocFacturacion, IdCatalogoCuentasSH, Poliza,
							IsEditable, CostosAtribuiblesAdministracion, EstadoDePresentacion, MesCertificadoCIEP, IdGastoRubro, PCN, Importado, BitPCNP,
							IdCBSISH, IdAceptacionPedidoDetalle, MesGasto, ModificadoEn, CapexOpexEdicion)
			SELECT			R.IdPrograma, R.IdFactura, RES.MontoRegistroPorcentaje, R.InicioEjecucion, R.FinEjecucion, R.Comentarios, MesPresentacion, @IdClvEstado, @IdUsuario,
							IdUsuarioModPor, FecMovto, IdInstalacion, @IdUsuario, Fila, IdPedimentoComprobante, CvTipoDocFacturacion, IdCatalogoCuentasSH, Poliza,
							IsEditable, CostosAtribuiblesAdministracion, EstadoDePresentacion, MesCertificadoCIEP, IdGastoRubro, PCN, Importado, BitPCNP,
							IdCBSISH, IdAceptacionPedidoDetalle, MesGasto, ModificadoEn, CapexOpexEdicion 
			FROM CO_Registro R 
			INNER JOIN #REGISTRO_RES RES ON R.IdRegistro = RES.IdRegistro

			--SELECT * FROM #RegistroABorrar
			
			DELETE CO_RegistroMarkup WHERE GastoId IN (SELECT IdRegistro FROM #RegistroABorrar)
			DELETE FROM CO_Registro WHERE IdRegistro IN (SELECT IdRegistro FROM #RegistroABorrar)
	 END

