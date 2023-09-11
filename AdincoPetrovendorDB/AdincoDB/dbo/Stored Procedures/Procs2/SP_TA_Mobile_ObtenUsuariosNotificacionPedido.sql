USE Adinco
-- Modified:	David De La Cruz
-- Create date: 09/09/2023
-- Description:	Se obtiene la información para mandar mensaje al siguiente aprobador
--**************************************************************
DROP PROC IF EXISTS SP_TA_Mobile_ObtenUsuariosNotificacionPedido
GO
create proc SP_TA_Mobile_ObtenUsuariosNotificacionPedido
@IdOperacion int,
@version int
as
begin
DECLARE @TipoFlujo int = 0;


SET @TipoFlujo = (SELECT FT.IdTipoFlujo FROM Petrovendor..TA_Operacion O
INNER JOIN Petrovendor..TA_FlujoTarea AS FT (NOLOCK) ON O.IdFlujoTarea = FT.IdFlujoTarea
WHERE IdOperacion = @IdOperacion)

if @TipoFlujo = 1 --Serial
begin
	SELECT	

					   O.IdOperacion, 
                       FT.IdTipoFlujo, 
                       O.IdEstatusOperacion, 
                       E.Nombre, 
                       O.IdAsignador, 
                       T.IdAprobador, 
                       U.Nombre, 
                       U.Correo, 
                       T.NoSecuencia, 
                       T.IdEstatus, 
                       E.Name,
					   U.IdUsuarioADINCO,
					   C.IdContrato,
					   AC.NombreAreaContractual,
					   PG.IdPedido
					   FROM Petrovendor..TA_Operacion AS O (NOLOCK)
                     INNER JOIN Petrovendor..MM_Pedido AS P (NOLOCK) ON O.IdDocumento = P.IdSolicitudPedido
                     INNER JOIN Petrovendor..TA_Tarea AS T (NOLOCK) ON O.IdOperacion = T.IdOperacion
                     INNER JOIN Petrovendor..S_Usuario AS U (NOLOCK) ON T.IdAprobador = U.IdUsuario
                     INNER JOIN Petrovendor..TA_FlujoTarea AS FT (NOLOCK) ON O.IdFlujoTarea = FT.IdFlujoTarea
                     INNER JOIN Petrovendor..TA_Estatus AS E (NOLOCK) ON O.IdEstatusOperacion = E.IdEstatus
					 INNER JOIN Adinco..CO_Contrato as C on P.IdContrato = C.IdContrato
					 INNER JOIN adinco..CO_AreaContractual as AC on C.IdAreaContractual = AC.IdAreaContractual
					 JOIN Petrovendor..MM_Pedidos AS PG  (NOLOCK)ON P.IdPedido = PG.IdIdentificador
                WHERE O.IdOperacion = @IdOperacion
                      AND P.Version = @version
					  and T.IdEstatus in (1,4)
            GROUP BY O.IdOperacion, 
                         FT.IdTipoFlujo, 
                         O.IdEstatusOperacion, 
                         E.Nombre, 
                         O.IdAsignador, 
                         T.IdAprobador, 
                         U.Nombre, 
                         U.Correo, 
                         T.NoSecuencia, 
                         T.IdEstatus, 
                         E.Name,
						 U.IdUsuarioADINCO,
						 C.IdContrato,
						 NombreAreaContractual,
						 PG.IdPedido
                ORDER BY T.NoSecuencia ASC
end
end
