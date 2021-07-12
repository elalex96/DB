
CREATE PROC [dbo].[p_CO_WDEA_Produccion_Diaria_Detalle_INS]
@IdDetalle	int OUT,
@Id	int,
@Pozo	varchar(500),
@BateriaSeparacion	varchar(500),
@Operativo	bit,
@Descarga	varchar(10),
@Sistema	varchar(100),
@BN	varchar(10),
@MedicionFecha	datetime,
@MedicionCIA	varchar(100),
@MedicionQBruto	float,
@MedicionQNeto	float,
@MedicionQAgua	float,
@MedicionFAgua	float,
@MedicionQGasTotal	float,
@MedicionQGasForm	float,
@MedicionQGasiny	float,
@CA_LAB_Fw	float,
@ProduccionQBruto	float,
@ProduccionQNeto	float,
@ProduccionQAgua	float,
@ProduccionFAgua	float,
@ProduccionQGasTotal	float,
@ProduccionQGasForm	float,
@ProduccionQGasiny	float,
@ProduccionPGasiny	float,
@ProduccionRGA	float,
@ProduccionEstTp	varchar(100),
@ProduccionPTP	float,
@ProduccionObservaciones	varchar(500),
@EstadoQBruto	float,
@EstadoQNeto	float,
@EstadoQAgua	float,
@EstadoFAgua	float,
@EstadoQGasTotal	float,
@EstadoQGasForm	float,
@EstadoQGasiny	float,
@EstadoRGA	float,
@DiferenciaQBruto	float,
@DiferenciaQNeto	float,
@DiferenciaQAgua	float,
@DiferenciaFAgua	float,
@DiferenciaQGasTotal	float,
@DiferenciaQGasForm	float,
@DiferenciaQGasiny	float,
@DiferenciaRGA	float,
@DiferenciaObservaciones	varchar(500),
@MovimientoPozo	varchar(500),
@MovimientoSistema	varchar(500),
@MovimientoBateria	varchar(500),
@Movimiento	varchar(500),
@MovimientoHrsCierre	varchar(500),
@MovimientoPB	float,
@MovimientoAgua	float,
@MovimientoPN	float,
@MovimientoGF	float,
@MovimientoGI	float,
@MovimientoPB_BLS	float,
@MovimientoPN_BLS	float,
@MovimientoPRES_TP	float,
@MovimientoPRES_LDD	float,
@MovimientoAjusteEst	varchar(100),
@MovimientoAjustePB	float,
@MovimientoAjustePN	float,
@MovimientoAjusteGF	float,
@MovimientoAjusteGI	float,
@CreadoPor	int,
@Error  varchar(250) OUT
AS
BEGIN

BEGIN TRY

	INSERT INTO [dbo].[CO_WDEA_Produccion_Diaria_Detalle]
			   ([Id]
			   ,[Pozo]
			   ,[BateriaSeparacion]
			   ,[Operativo]
			   ,[Descarga]
			   ,[Sistema]
			   ,[BN]
			   ,[MedicionFecha]
			   ,[MedicionCIA]
			   ,[MedicionQBruto]
			   ,[MedicionQNeto]
			   ,[MedicionQAgua]
			   ,[MedicionFAgua]
			   ,[MedicionQGasTotal]
			   ,[MedicionQGasForm]
			   ,[MedicionQGasiny]
			   ,[CA_LAB_Fw]
			   ,[ProduccionQBruto]
			   ,[ProduccionQNeto]
			   ,[ProduccionQAgua]
			   ,[ProduccionFAgua]
			   ,[ProduccionQGasTotal]
			   ,[ProduccionQGasForm]
			   ,[ProduccionQGasiny]
			   ,[ProduccionPGasiny]
			   ,[ProduccionRGA]
			   ,[ProduccionEstTp]
			   ,[ProduccionPTP]
			   ,[ProduccionObservaciones]
			   ,[EstadoQBruto]
			   ,[EstadoQNeto]
			   ,[EstadoQAgua]
			   ,[EstadoFAgua]
			   ,[EstadoQGasTotal]
			   ,[EstadoQGasForm]
			   ,[EstadoQGasiny]
			   ,[EstadoRGA]
			   ,[DiferenciaQBruto]
			   ,[DiferenciaQNeto]
			   ,[DiferenciaQAgua]
			   ,[DiferenciaFAgua]
			   ,[DiferenciaQGasTotal]
			   ,[DiferenciaQGasForm]
			   ,[DiferenciaQGasiny]
			   ,[DiferenciaRGA]
			   ,[DiferenciaObservaciones]
			   ,[MovimientoPozo]
			   ,[MovimientoSistema]
			   ,[MovimientoBateria]
			   ,[MovimientoHrsCierre]
			   ,[MovimientoPB]
			   ,[MovimientoAgua]
			   ,[MovimientoPN]
			   ,[MovimientoGF]
			   ,[MovimientoGI]
			   ,[MovimientoPB_BLS]
			   ,[MovimientoPN_BLS]
			   ,[MovimientoPRES_TP]
			   ,[MovimientoPRES_LDD]
			   ,[MovimientoAjusteEst]
			   ,[MovimientoAjustePB]
			   ,[MovimientoAjustePN]
			   ,[MovimientoAjusteGF]
			   ,[MovimientoAjusteGI]
			   ,[CreadoEl]
			   ,[CreadoPor])
		 VALUES
			   (
			   @Id, 
			   @Pozo, 
			   @BateriaSeparacion, 
			   @Operativo, 
			   @Descarga, 
			   @Sistema, 
			   @BN, 
			   @MedicionFecha, 
			   @MedicionCIA, 
			   @MedicionQBruto, 
			   @MedicionQNeto, 
			   @MedicionQAgua, 
			   @MedicionFAgua, 
			   @MedicionQGasTotal, 
			   @MedicionQGasForm, 
			   @MedicionQGasiny, 
			   @CA_LAB_Fw, 
			   @ProduccionQBruto, 
			   @ProduccionQNeto, 
			   @ProduccionQAgua, 
			   @ProduccionFAgua, 
			   @ProduccionQGasTotal, 
			   @ProduccionQGasForm, 
			   @ProduccionQGasiny, 
			   @ProduccionPGasiny, 
			   @ProduccionRGA, 
			   @ProduccionEstTp, 
			   @ProduccionPTP, 
			   @ProduccionObservaciones, 
			   @EstadoQBruto, 
			   @EstadoQNeto, 
			   @EstadoQAgua, 
			   @EstadoFAgua, 
			   @EstadoQGasTotal, 
			   @EstadoQGasForm, 
			   @EstadoQGasiny, 
			   @EstadoRGA, 
			   @DiferenciaQBruto, 
			   @DiferenciaQNeto, 
			   @DiferenciaQAgua, 
			   @DiferenciaFAgua, 
			   @DiferenciaQGasTotal, 
			   @DiferenciaQGasForm, 
			   @DiferenciaQGasiny, 
			   @DiferenciaRGA, 
			   @DiferenciaObservaciones, 
			   @MovimientoPozo, 
			   @MovimientoSistema, 
			   @MovimientoBateria, 
			   @MovimientoHrsCierre, 
			   @MovimientoPB, 
			   @MovimientoAgua, 
			   @MovimientoPN, 
			   @MovimientoGF, 
			   @MovimientoGI, 
			   @MovimientoPB_BLS, 
			   @MovimientoPN_BLS, 
			   @MovimientoPRES_TP, 
			   @MovimientoPRES_LDD, 
			   @MovimientoAjusteEst, 
			   @MovimientoAjustePB, 
			   @MovimientoAjustePN, 
			   @MovimientoAjusteGF, 
			   @MovimientoAjusteGI, 
			   GETDATE(), 
			   @CreadoPor )

			   SET @IdDetalle = SCOPE_IDENTITY()

END TRY
BEGIN CATCH
	SET @Error = ERROR_MESSAGE()
END CATCH
END



