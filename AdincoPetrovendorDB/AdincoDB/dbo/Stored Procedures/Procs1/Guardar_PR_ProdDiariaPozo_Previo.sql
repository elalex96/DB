CREATE PROCEDURE [dbo].[Guardar_PR_ProdDiariaPozo_Previo]
    @Fecha DATETIME,
    @VolumenBombeado DECIMAL(24, 8),
    @VolumenMedido DECIMAL(24, 8),
    @VolumenReportado DECIMAL(24, 8),
    @DiferenciaVolumenBM DECIMAL(24, 8),
    @DiferenciaVolumenMR DECIMAL(24, 8),
    @UsuarioModificacion INT,
    @IdContrato INT,
    @Table_PR_ProdDiariaPozo_Previo Type_PR_ProdDiariaPozo_Previo READONLY
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN
        DECLARE @Bloque INT,
                @IdEncabezado INT
		DECLARE @ErrorMessage NVARCHAR(4000)

        SELECT @Bloque = Id
        FROM PR_BLOQUE
        WHERE IdContrato = @IdContrato

        INSERT INTO PR_ProdDiaria_Previo
        (
            Bloque,
            Fecha,
            VolumenBombeado,
            VolumenMedido,
            VolumenReportado,
            DiferenciaVolumenBM,
            DiferenciaVolumenMR,
            FechaModificacion,
            UsuarioModificacion,
            Estatus,
            Algoritmo,
            Temperatura
        )
        SELECT @Bloque,
               @Fecha,
               @VolumenBombeado,
               @VolumenMedido,
               @VolumenReportado,
               @DiferenciaVolumenBM,
               @DiferenciaVolumenMR,
               GETDATE(),
               @UsuarioModificacion,
               1,
               0,
               20

        SELECT @IdEncabezado = SCOPE_IDENTITY()

        INSERT INTO PR_ProdDiariaPozo_Previo
        (
            ProdDiaria,
            Fecha,
            Estacion,
            Pozo,
            NombreEstacion,
            Medidor,
            Nominal,
            Fuente,
            Operando,
            Est_64Plg,
            Cabeza,
            Linea,
            Temperatura,
            GastoGas,
            ProdCondensadoNeto,
            ProdAceiteNeto,
            ProdPetroleoBruto,
            Agua,
            Comentarios,
            IdUnidad,
            IdSistema,
            EPM,
			ProgramaInmediato,
			Seguimiento
        )
        SELECT @IdEncabezado,
               Fecha,
               Estacion,
               Pozo,
               NombreEstacion,
               NULL,
               Nominal,
               Fuente,
               Operando,
               Est_64Plg,
               Cabeza,
               Linea,
               20,
               GastoGas,
               NULL,
               ProdAceiteNeto,
               ProdPetroleoBruto,
               Agua,
               Comentarios,
               IdUnidad,
               IdSistema,
               EPM,
			   ProgramaInmediato,
			   Seguimiento
        FROM @Table_PR_ProdDiariaPozo_Previo

        COMMIT TRAN
    END TRY
    BEGIN CATCH
		
		SELECT @ErrorMessage = ERROR_MESSAGE()
        ROLLBACK TRAN
		
		RAISERROR(@ErrorMessage, 17, 1)
    END CATCH;

END


