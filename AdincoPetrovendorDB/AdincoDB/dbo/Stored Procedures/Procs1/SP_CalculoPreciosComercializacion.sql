CREATE PROCEDURE [dbo].[SP_CalculoPreciosComercializacion]   
    @IdTipoHidrocarburo int,   
    @MesParam int,
	@AnioParam int,
	@IdContrato int    
AS   

    SELECT IdOperacionComercializacion,IdContrato,MesReporte,IdTipoHidrocarburo, VolumenVendido,PrecioVentaUnitario,NuevoPrecioVentaUnitario
	FROM COM_OperacionComercializacion 
	WHERE IdTIpoHidrocarburo = @IdTipoHidrocarburo and YEAR(mesreporte) = @AnioParam and MONTH(mesreporte)= @MesParam AND IdContrato = @IdContrato;