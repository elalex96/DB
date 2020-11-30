-- =============================================
-- Author:		Reyna Olvera
-- Create date: 26/04/2018
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[EN_VerificaExistenciAprobadores] --44816,3,2
    @idInstanciaEntregable INT,
    @idContrato INT,
    @idUsuario INT
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @UsuariosRevision   INT,
            @UsuariosAprobacion INT;

    SELECT @UsuariosRevision = COUNT(A1.idusuario)
      FROM EN_InstanciasEntregable IE
      JOIN EN_Actividad A1
        ON  IE.IdContratoEntregable	=	A1.IdContratoEntregable
       AND	A1.EstadoID	= 10001
     WHERE idInstanciaEntregable	=	@idInstanciaEntregable;

    SELECT @UsuariosAprobacion = COUNT(A2.idUsuario)
      FROM EN_InstanciasEntregable IE
      JOIN EN_Actividad A2
        ON IE.IdContratoEntregable	=	A2.IdContratoEntregable 
       AND A2.EstadoID	=	10002
     WHERE idInstanciaEntregable	=	@idInstanciaEntregable;

    SELECT @UsuariosRevision AS UsuariosRevision,
           @UsuariosAprobacion AS UsuariosAprobacion;
END;

