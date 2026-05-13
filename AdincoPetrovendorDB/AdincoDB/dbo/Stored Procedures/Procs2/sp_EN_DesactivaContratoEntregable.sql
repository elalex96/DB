-- =============================================
-- Author:		Reyna Olvera
-- Create date: 2019/02/14
-- Description:Desactiva contrato entregable
-- =============================================

Create PROCEDURE [dbo].[sp_EN_DesactivaContratoEntregable]-- 16841,10061,3
    @IdContratoEntregable INT,
    @idUsuario INT,
    @idContrato INT
AS
BEGIN

	Update EN_contratoEntregable 
	Set Activo=0
	Where IdContratoEntregable=@IdContratoEntregable
     IF @@ERROR <> 0
	 Begin
        SELECT ERROR_MESSAGE() AS error
		END
    ELSE
	Begin
		SELECT '' AS error
   END
END;
