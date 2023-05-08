-- =============================================
-- Author:		Reyna Olvera
-- Create date: 2019/02/14
-- Description:Extrae Responsables
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_AgregaProcesosDeMacro]
    @IdProceso INT,
    @MacroProceso INT,
    @idUsuario INT,
    @idContrato INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @orden INT = 0, @CountProcesos int=0;

    SELECT @orden = ISNULL(MAX(orden), 0)
    FROM EN_MacroProcesosRelacion
    WHERE idMacroProceso = @MacroProceso;

	Select @CountProcesos=COUNT(1)
	FROM EN_MacroProcesosRelacion
    WHERE idMacroProceso = @MacroProceso;
   
	SET @orden = @orden + 1;
	
    INSERT INTO EN_MacroProcesosRelacion (idMacroProceso, idProcesoHijo, CreadoPor, CreadoEn, ModificadoPor,
                                          ModificadoEn, Activo, Orden)
    VALUES (@MacroProceso, @IdProceso, @idUsuario, GETDATE(), @idUsuario, GETDATE(), 1,Case @CountProcesos
	when 0 then 0 else @orden end);

END;