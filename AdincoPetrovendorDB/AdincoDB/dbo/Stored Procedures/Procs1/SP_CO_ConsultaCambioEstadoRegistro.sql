-- =============================================
-- Author:		Marcos Neri
-- Create date: 10-01-2020
-- Description:	Consulta Id de estado de Registros
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ConsultaCambioEstadoRegistro] 
-- Add the parameters for the stored procedure here
-- [sp_CO_ConsultaCambioEstadoRegistro] 10007
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         SELECT IdEstadoRegistro, 
                NombreEstado
         FROM dbo.CO_EstadoRegistro
         WHERE IdEstadoRegistro IN(10000, 10004);
     END;