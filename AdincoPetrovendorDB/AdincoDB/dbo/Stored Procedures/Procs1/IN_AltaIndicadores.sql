-- =============================================
-- Author:		ReynaOlvera
-- Create date: 05-01-2018
-- Description:	Alta Indicadores
-- =============================================
CREATE PROCEDURE IN_AltaIndicadores
	-- Add the parameters for the stored procedure here
	@indicador int, 
	@idInsumo int,
	@idContrato int,
	@idUsuario int,
	@periodo date,
	@valorCantidad decimal(24,16)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   
Declare	
		@idControlInsumo int,
		@NameMes varchar(500),
		@Año int,
		@idInsumoIndicador int


--Nombre del mes y el año
set 
language 'spanish'
SELECT @NameMes = DATENAME(month, @periodo); 

SELECT @Año=year(@periodo);

Select @idInsumoIndicador= idInsumoIndicador from IN_InsumoIndicador where idInsumo=@idInsumo and idIndicador=@indicador;

Select @idControlInsumo=idControlInsumo 
from IN_controlInsumo
where idContrato=@idContrato And idInsumoIndicador=@idInsumoIndicador

Insert into in_insumoPorMes (valorCantidad,FechaCapturado,PeriodoMes,idControlInsumo,Año,periodo) 
values (@valorCantidad,GetDate(),@NameMes,@idControlInsumo,@Año,@periodo);
 
execute dbo.in_CalculaIndicador @indicador,@idContrato,@idUsuario, @periodo

END

