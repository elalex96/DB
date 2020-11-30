-- =============================================
-- Author:		Reyna Olvera
-- Create date: 10/04/2018
-- Description:Guarda URL de los aprobdores
-- =============================================
CREATE PROCEDURE [dbo].[EN_GuardaURLAprobadoresInstancias]
    -- Add the parameters for the stored procedure here
    @idUsuario INT,
    @idContrato INT,
    @idContratoEntregable INT,
    @idInstanciaEntregable INT,
    @FechaFinalizacion DATETIME,
    @tipoOperacion INT,
    @correos NVARCHAR(MAX),
    @idUsuarioTarea INT,
    @NombreUsuario NVARCHAR(MAX),
    @ActividadID INT,
    @EnlaceDetalle NVARCHAR(MAX),
    @EnlaceAprobado NVARCHAR(MAX),
    @EnlaceRechazo NVARCHAR(MAX),
    @NombreInstancia NVARCHAR(MAX),
    @FechaInstancia NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Count INT;
    IF (@idContratoEntregable = 0)
    BEGIN
        SELECT @idContratoEntregable = IdContratoEntregable
          FROM dbo.EN_InstanciasEntregable
         WHERE idInstanciaEntregable = @idInstanciaEntregable;
    END;

    SELECT @NombreInstancia = DocumentoEntregable,
           @FechaInstancia = FechasLimiteAprobacion
      FROM dbo.EN_InstanciasEntregable
      JOIN dbo.EN_ContratoEntregable
        ON EN_ContratoEntregable.IdContratoEntregable = EN_InstanciasEntregable.IdContratoEntregable
      JOIN dbo.EN_Entregable
        ON EN_Entregable.IdEntregable                 = EN_ContratoEntregable.IdEntregable
     WHERE idInstanciaEntregable = @idInstanciaEntregable;

    SELECT @Count = COUNT(*)
      FROM EN_URLResponsablesEntregables
     WHERE idInstanciaEntregable = @idInstanciaEntregable
       AND tipoOperacion         = @tipoOperacion
       AND idUsuarioTarea        = @idUsuarioTarea
       AND ActividadID           = @ActividadID;

    IF (@Count = 0)
    BEGIN
        INSERT INTO EN_URLResponsablesEntregables (idContratoEntregable,
                                                   idInstanciaEntregable,
                                                   FechaFinalizacion,
                                                   tipoOperacion,
                                                   correos,
                                                   idUsuarioTarea,
                                                   NombreUsuario,
                                                   ActividadID,
                                                   EnlaceDetalle,
                                                   EnlaceAprobado,
                                                   EnlaceRechazo,
                                                   NombreInstancia,
                                                   FechaInstancia,
                                                   CreadoPor,
                                                   CreadoEn,
                                                   ModificadoPor,
                                                   ModificadoEn,
                                                   Activo)
        VALUES (@idContratoEntregable, @idInstanciaEntregable, @FechaFinalizacion, @tipoOperacion, @correos,
                @idUsuarioTarea, @NombreUsuario, @ActividadID, @EnlaceDetalle, @EnlaceAprobado, @EnlaceRechazo,
                @NombreInstancia, @FechaInstancia, @idUsuario, GETDATE(), @idUsuario, GETDATE(), 1);
    END;
    ELSE
    BEGIN
        UPDATE EN_URLResponsablesEntregables
           SET idContratoEntregable = @idContratoEntregable,
               FechaFinalizacion = @FechaFinalizacion,
               correos = @correos,
               NombreUsuario = @NombreUsuario,
               EnlaceDetalle = @EnlaceDetalle,
               EnlaceAprobado = @EnlaceAprobado,
               EnlaceRechazo = @EnlaceRechazo,
               NombreInstancia = @NombreInstancia,
               FechaInstancia = @FechaInstancia,
               CreadoPor = @idUsuario,
               CreadoEn = GETDATE(),
               ModificadoPor = @idUsuario,
               ModificadoEn = GETDATE(),
               Activo = 1
         WHERE idInstanciaEntregable = @idInstanciaEntregable
           AND tipoOperacion         = @tipoOperacion
           AND idUsuarioTarea        = @idUsuarioTarea
           AND ActividadID           = @ActividadID;
    END;

END;

