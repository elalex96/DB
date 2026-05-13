-- =============================================
-- Author:	Daniel AC
-- Create date: 2021
-- Description:Crea excepciones de fecha multiples
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_RegistraExcepcionesFechaMultiple]-- '564865,',10150,3,'','2019-12-05 00:00:00'
    @IdInstancias  NVARCHAR(MAX),
    @UsuarioId     INT,
    @ContratoId    INT,   
	@Comentario  NVARCHAR(MAX),
	@NuevaFechaLimite DATETIME
AS
    BEGIN
	
	DECLARE @EntregablesInstancias AS TABLE
    (
        IdRow INT IDENTITY(1, 1),
        EntregableInstanciaId INT
    );
	
    INSERT INTO @EntregablesInstancias
    (
        EntregableInstanciaId
    )    
	SELECT splitdata
	FROM dbo.fnSplitString(@IdInstancias,',')
	
	 


	UPDATE IE
    SET IE.FechasLimiteElaboracion = CASE WHEN IE.FechaCalculadaEntregaReg < @NuevaFechaLimite THEN
                                            IE.FechasLimiteElaboracion
                                        ELSE
                                            DATEADD(DAY,-7,IE.FechasLimiteElaboracion)
                                        END,
        IE.FechasLimiteRevision =  CASE WHEN IE.FechaCalculadaEntregaReg < @NuevaFechaLimite THEN
                                            IE.FechasLimiteRevision
                                        ELSE
                                            DATEADD(DAY,-7,IE.FechasLimiteRevision)
                                        END,
        IE.FechaInicioElaboracion = CASE WHEN IE.FechaCalculadaEntregaReg < @NuevaFechaLimite THEN
                                            IE.FechasLimiteRevision
                                        ELSE
                                            DATEADD(DAY,-7,IE.FechaInicioElaboracion)
                                        END,
        IE.FechaEnvioMensajeAtrasoRevision = CASE WHEN IE.FechaCalculadaEntregaReg < @NuevaFechaLimite THEN
                                            IE.FechasLimiteRevision
                                        ELSE
                                            DATEADD(DAY,-7,IE.FechaEnvioMensajeAtrasoRevision)
                                        END,
        IE.FechasLimiteAprobacion = @NuevaFechaLimite,
        IE.FechaCalculadaEntregaReg = @NuevaFechaLimite,
        IE.ContieneAjusteFechas = 1,
        IE.ModificadoEn = GETDATE(),
        IE.ModificadoPor = @UsuarioId
    FROM EN_InstanciasEntregable IE       
    JOIN @EntregablesInstancias EIM
    ON IE.idInstanciaEntregable =EIM.EntregableInstanciaId

        
	SELECT 
	EntregableInstanciaId = EI.idInstanciaEntregable, 
	Detalle='Fecha actualizada correctamente' 
	FROM @EntregablesInstancias EIM
	JOIN EN_InstanciasEntregable EI
	ON EIM.EntregableInstanciaId=EI.idInstanciaEntregable


END;
	
