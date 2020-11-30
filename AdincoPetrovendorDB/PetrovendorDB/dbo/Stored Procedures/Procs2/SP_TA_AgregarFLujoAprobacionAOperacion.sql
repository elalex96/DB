-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <21/11/19>
-- Description:	<Agrega un flujo de aprobacion a una factura enviada sin flujo de aprobación>
-- =============================================
CREATE PROCEDURE SP_TA_AgregarFLujoAprobacionAOperacion @IdOperacion   INT, 
                                                        @IdFlujoTarea  INT, 
                                                        @IdEstadoFlujo INT
AS
    BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;
        UPDATE dbo.TA_Operacion
          SET 
              IdFlujoTarea = @IdFlujoTarea, 
              IdEstadoFlujo = @IdEstadoFlujo, -- iniciada
              FechaModificacion = GETDATE(), 
              IdEstatusOperacion = 1 --pendiente
        WHERE IdOperacion = @IdOperacion;
        SELECT IdFlujoTarea, 
               IdAsignador
        FROM dbo.TA_Operacion
        WHERE IdOperacion = @IdOperacion;
    END;
