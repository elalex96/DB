CREATE TABLE [dbo].[AP_PerfilUsuario] (
    [PerfilUsuarioID] INT IDENTITY (1, 1) NOT NULL,
    [UsuarioID]       INT NOT NULL,
    [PerfilID]        INT NOT NULL,
    [CreadoPor]       INT NULL,
    [RandomUpdate]    INT NULL,
    CONSTRAINT [PK_PerfilUsuario] PRIMARY KEY CLUSTERED ([PerfilUsuarioID] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AP_PerfilUsuario_AP_Perfil] FOREIGN KEY ([PerfilID]) REFERENCES [dbo].[AP_Perfil] ([IdPerfil]),
    CONSTRAINT [FK_PerfilUsuario_Usuario] FOREIGN KEY ([UsuarioID]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);


GO
create TRIGGER [dbo].[AP_PerfilUsuario_INSERT] ON [dbo].[AP_PerfilUsuario]
FOR INSERT
NOT FOR REPLICATION
AS
BEGIN
-- =============================================
-- Author:		Bárbara Arrañaga
-- Create date: 2018-03-15
-- Description:	Se crea trigger para registrar la relacion de usuario proveedor en PetroVendor
-- =============================================
IF @@ROWCOUNT = 0
    GOTO FIN;

SET NOCOUNT ON;

			-- SE INSERTA LA RELACION EN S_USUARIOPROVEEDOR
			INSERT INTO Petrovendor.dbo.S_UsuarioProveedor
			(
			    IdUsuario,
			    IdProveedor,
			    IdTipoPaquete,
			    IsAdmin,
			    IdContrato
			)
			 SELECT
 				PU.IdUsuario,
				P.IdProveedor,
				NULL	AS [IdTipoPaquete],
				0		AS [IsAdmin],
				C.IdContrato
			 FROM 
				INSERTED	I
			JOIN
				PETROVENDOR.dbo.S_Usuario	PU
				ON	PU.IdUsuarioADINCO	=	I.UsuarioID
			JOIN
				Adinco.dbo.AP_Perfil	AP
				ON	I.PerfilID	=	AP.IdPerfil
			JOIN
				Adinco.dbo.CO_Contrato	C
				ON	AP.IdContrato	=	C.IdContrato
			JOIN
				Adinco.dbo.CO_Contratista	CC
				ON	C.IdContratista	=	CC.IdContratista
			JOIN
				PETROVENDOR.dbo.S_Proveedor		P
				ON	CC.RFC COLLATE Modern_Spanish_CI_AS	=	P.RFC
			LEFT JOIN
				PETROVENDOR.dbo.S_UsuarioProveedor	UP
				ON	PU.IdUsuario	=	UP.IdUsuario
				AND	P.IdProveedor	=	UP.IdProveedor
				AND	C.IdContrato	=	UP.idContrato
			WHERE
				UP.idContrato IS NULL
			GROUP BY
				PU.IdUsuario,
				P.IdProveedor,
				C.IdContrato

FIN:
END
GO
create TRIGGER [dbo].[AP_PerfilUsuario_DELETE] ON [dbo].[AP_PerfilUsuario]
FOR DELETE
NOT FOR REPLICATION
AS
BEGIN
-- =============================================
-- Author:		Bárbara Arrañaga
-- Create date: 2018-03-15
-- Description:	Se crea trigger para registrar la relacion de usuario proveedor en PetroVendor
-- =============================================
IF @@ROWCOUNT = 0
    GOTO FIN;

SET NOCOUNT ON;
			-- SE BORRA LA RELACION DE USUARIO PROVEEDOR EN PETROVENDOR QUE SE HAYA ELIMINADO EN ADINCO
			DELETE	UP
			 FROM 
				DELETED		D
			JOIN
				PETROVENDOR.dbo.S_Usuario	PU
				ON	PU.IdUsuarioADINCO	=	D.UsuarioID
			JOIN
				Adinco.dbo.AP_Perfil	AP
				ON	D.PerfilID	=	AP.IdPerfil
			JOIN
				Adinco.dbo.CO_Contrato	C
				ON	AP.IdContrato	=	C.IdContrato
			JOIN
				Adinco.dbo.CO_Contratista	CC
				ON	C.IdContratista	=	CC.IdContratista
			JOIN
				PETROVENDOR.dbo.S_Proveedor		P
				ON	CC.RFC COLLATE Modern_Spanish_CI_AS	=	P.RFC
			JOIN
				PETROVENDOR.dbo.S_UsuarioProveedor	UP
				ON	PU.IdUsuario	=	UP.IdUsuario
				AND	P.IdProveedor	=	UP.IdProveedor
				AND	C.IdContrato	=	UP.idContrato
			
FIN:
END


