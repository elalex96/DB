-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <13/01/20>
-- Description:	<Actualiza el idtabla en caso de ser necesario>
-- =============================================
CREATE PROCEDURE SP_N_ActualizarIdTablaNotificacion @IdOperacion INT, 
                                                    @IdTabla     INT
AS
    BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;
        UPDATE dbo.Notificacion
          SET 
              IdTabla = @IdTabla
        WHERE IdOperacion = @IdOperacion;
    END;
