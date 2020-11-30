-- =============================================
-- Author:      Reyna Olvera
-- Create date: 20181023
-- Description: Llama los entregables
-- =============================================
CREATE PROCEDURE sp_EN_UPDATEActividades --3,10061,'test',30,0,'10678,10684'
    @idContrato INT,
    @idUsuario INT,
    @NombreActividad VARCHAR(Max),
    @IdActividad INT
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @Count INT,@error NVARCHAR(MAX);
    SELECT @Count = COUNT(*)
    FROM en_actividades
    WHERE LTRIM(RTRIM(NombreActividad)) = LTRIM(RTRIM(@NombreActividad));

    -----------------------------------------Actividades
    IF (@Count = 0)
    BEGIN
       Update  dbo.EN_Actividades
          SET   NombreActividad=@NombreActividad,
            ModificadoPor=@idUsuario,
            ModificadoEl=GETDATE(),
            Activo=1
     where IdActividad=@IdActividad
      
    END;
    ELSE
    BEGIN
        SET @error = 'Ya existe una actividad con el mismo nombre';
        SELECT @error;
    END;

END;