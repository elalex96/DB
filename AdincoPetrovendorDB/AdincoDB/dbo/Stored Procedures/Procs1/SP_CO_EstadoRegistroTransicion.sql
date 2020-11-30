-- =============================================
-- Author:		Manuel CD
-- Create date: 27-09-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_EstadoRegistroTransicion] 
	-- Add the parameters for the stored procedure here
@IdUsuario        INT,
@EstadoRegistroID INT,
@IdContrato INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT --R.IdRegistro,
         ERT.IdEstadoDestino,
         ERT.IdEstadoOrigen,
         ER.NombreEstado AS EstadoActual,
         ERT.Descripcion,
         ERD.NombreEstado AS CambiarA
         FROM CO_EstadoRegistroTransicion ERT
              JOIN CO_EstadoRegistroUsuario ERU ON ERT.IdEstadoOrigen = ERU.IdClvEstado
              JOIN CO_EstadoRegistro_V2 ER ON ERT.IdEstadoOrigen = ER.IdClvEstado
              JOIN CO_EstadoRegistro_V2 ERD ON ERT.IdEstadoDestino = ERD.IdClvEstado
              JOIN CO_Registro R ON ERT.IdEstadoOrigen = R.IdEstado
         WHERE ERU.IdUsuario = @IdUsuario
               AND R.IdRegistro = @EstadoRegistroID
			AND ER.IdContrato = @IdContrato
			AND ERD.IdContrato = @IdContrato
     END;
	--SP_CO_EstadoRegistroTransicion 2, 7107
	--SP_CO_EstadoRegistroTransicion 10002, 1631, 3

