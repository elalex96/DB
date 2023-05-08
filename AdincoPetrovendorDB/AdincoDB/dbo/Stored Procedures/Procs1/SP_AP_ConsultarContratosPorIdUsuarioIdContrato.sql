-- =============================================
-- Author:Daniel AC
-- Create date: 01-03-2018
-- Description:	Buscar el nombre del contrato por idcontrato y usuario
-- =============================================
create PROCEDURE [dbo].[SP_AP_ConsultarContratosPorIdUsuarioIdContrato] 
	-- Add the parameters for the stored procedure here
	@IdUsuario int = 0,
	@IdContrato INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SELECT    distinct    CO_Contrato.NumeroContrato, CO_AreaContractual.NombreAreaContractual, CO_Contrato.NumeroContrato + ' - ' + CO_AreaContractual.NombreAreaContractual AS Contrato,
                          CO_Contrato.IdContrato, CO_AreaContractual.IdAreaContractual
FROM            AP_PerfilUsuario AS PU INNER JOIN
                         AP_Usuario ON PU.UsuarioID = AP_Usuario.UsuarioID INNER JOIN
                         AP_Perfil ON PU.PerfilID = AP_Perfil.IdPerfil INNER JOIN
                         AP_Rol ON AP_Perfil.IdRol = AP_Rol.IdRol INNER JOIN
                         CO_Contrato ON AP_Perfil.IdContrato = CO_Contrato.IdContrato INNER JOIN
                         CO_AreaContractual ON CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual
WHERE        (@IdUsuario= PU.UsuarioID AND CO_Contrato.IdContrato=@IdContrato)

END
