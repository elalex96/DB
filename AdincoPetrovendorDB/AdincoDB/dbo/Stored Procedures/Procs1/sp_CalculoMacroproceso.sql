-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:	manda a llamar el calculo de macroproceso
-- =============================================
CREATE PROCEDURE sp_CalculoMacroproceso --12147,3,10061,'20190101','prueba',11785,0,1
	@IdMacroproceso int ,
	@idContrato int ,
	@idUsuario int ,
	@Fecha date,
	@DescripcionCalculo varchar(max),
	@idinstalacion int ,
	@guardar int,
	@TipoFechaSeleccionada BIT,-- 1=Inicial 0=final
	@idActividad INT
	AS
BEGIN
	IF(@TipoFechaSeleccionada=1)
	BEGIN
		Exec sp_GuardaSimulaCalculoFInicialMacro @IdMacroproceso,
		@idContrato,
		@idUsuario,
		@Fecha,
		@DescripcionCalculo,
		@idinstalacion,
		@guardar,
		@idActividad;
	END
ELSE
	BEGIN
		Exec sp_GuardaSimulaCalculoFinalMacro @IdMacroproceso,
		@idContrato,
		@idUsuario,
		@Fecha,
		@DescripcionCalculo,
		@idinstalacion,
		@guardar,
		@idActividad;
	END

END