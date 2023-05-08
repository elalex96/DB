
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <23-05-2018>
-- Description:	<Consulta para el combo de yacimientos>
-- =============================================

CREATE procedure [dbo].[CO_SP_ConsultaComboYacimientos]
	@IdContrato INT ,
	@IdUsuario INT =0
AS
BEGIN
	--SELECT IdYacimiento,
	--		NombreYacimiento
	--FROM dbo.CO_Yacimiento

		SELECT Y.IdYacimiento,
			NombreYacimiento
	FROM dbo.CO_AreaContractualYacimiento ACY
	JOIN dbo.CO_Yacimiento Y ON Y.IdYacimiento = ACY.IdYacimiento
	JOIN dbo.CO_AreaContractual AC ON AC.IdAreaContractual = ACY.IdAreaContractual
	JOIN dbo.CO_Contrato C ON C.IdAreaContractual = ACY.IdAreaContractual
	WHERE C.IdContrato=@IdContrato

END