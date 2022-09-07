-- ========================================================================
-- Author:		Manuel CD
-- Create date: 27-09-17
-- Description:	
-- ========================================================================
-- Modificado Por:		Neri del Angel
-- Fecha Modificación:	06 de Septiembre del 2022
-- Descripción:			Se agrega validacion del nuevo campo idestadopemex,
--						de la tabla [CO_RegistroMarkup]
--						en vez de la tabla CO_Registro.IdEstado
-- ========================================================================
CREATE PROCEDURE [dbo].[SP_CO_EstadoRegistroTransicion] 
    @IdUsuario INT,
    @EstadoRegistroID INT,
    @IdContrato INT
AS
BEGIN
    SET NOCOUNT ON;  
	DECLARE @IdEstadoBase INT;
	/**/
    IF NOT EXISTS
    (
        SELECT *
        FROM CO_RegistroMarkup
        WHERE GastoId = @EstadoRegistroID
              AND IdEstadoPemex IS NOT NULL
    )
    BEGIN
      SELECT TOP 1 @IdEstadoBase = CO_EstadoRegistro_V2.IdClvEstado FROM  CO_EstadoRegistro_V2 WHERE IdContrato = @IdContrato AND Descripcion= 'En revisión' AND NombreEstado = 'Revisión'
     UPDATE CO_RegistroMarkup SET IdEstadoPemex = @IdEstadoBase  WHERE GastoId = @EstadoRegistroID
    END;
   
     SELECT CO_EstadoRegistroTransicion.IdEstadoDestino,
               CO_EstadoRegistroTransicion.IdEstadoOrigen,
               CO_EstadoRegistro_V2.NombreEstado AS EstadoActual,
               CO_EstadoRegistroTransicion.Descripcion,
               CO_EstadoRegistro_V2_Destino.NombreEstado AS CambiarA
        FROM CO_EstadoRegistroTransicion
            JOIN CO_EstadoRegistroUsuario
                ON CO_EstadoRegistroTransicion.IdEstadoOrigen = CO_EstadoRegistroUsuario.IdClvEstado
            JOIN CO_EstadoRegistro_V2
                ON CO_EstadoRegistroTransicion.IdEstadoOrigen = CO_EstadoRegistro_V2.IdClvEstado
            JOIN CO_EstadoRegistro_V2 CO_EstadoRegistro_V2_Destino
                ON CO_EstadoRegistroTransicion.IdEstadoDestino = CO_EstadoRegistro_V2_Destino.IdClvEstado
            JOIN CO_RegistroMarkup
                ON CO_EstadoRegistroTransicion.IdEstadoOrigen = CO_RegistroMarkup.IdEstadoPemex
        WHERE CO_EstadoRegistroUsuario.IdUsuario = @IdUsuario
              AND CO_RegistroMarkup.GastoId = @EstadoRegistroID
              AND CO_EstadoRegistro_V2.IdContrato = @IdContrato
              AND CO_EstadoRegistro_V2_Destino.IdContrato = @IdContrato
END;