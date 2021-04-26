CREATE TABLE [dbo].[SIPAC_ImportRML_CONT_25_M](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdBitacora] [int] NOT NULL,
	[RF_00] [varchar](200) NULL,
	[RI_00] [varchar](200) NULL,
	[RF01_01] [varchar](200) NULL,
	[RMLCT25_00] [tinyint] NULL,
	[RMLCT25_01] [smallint] NULL,
	[RMLCT25_02] [int] NULL,
	[RMLCT25_03] [decimal](5, 2) NULL,
	[RMLCT25_04] [decimal](5, 2) NULL,
	[RMLCT25_05] [int] NULL,
	[RMLCT25_06] [int] NULL,
	[RMLCT25_07] [int] NULL,
	[RMLCT25_08] [int] NULL,
	[RMLCT25_09] [int] NULL,
	[RMLCT25_10] [int] NULL,
	[RMLCT25_11] [int] NULL,
	[RMLCT25_12] [int] NULL,
	[RMLCT25_13] [int] NULL,
	[RMLCT25_14] [int] NULL,
	[RMLCT25_15] [int] NULL,
	[RMLCT25_16] [int] NULL,
	[RMLCT25_17] [int] NULL,
	[RMLCT25_18] [int] NULL,
	[RMLCT25_19] [int] NULL,
	[RMLCT25_20] [int] NULL,
	[RMLCT25_21] [int] NULL,
	[RMLCT25_22] [decimal](10, 4) NULL,
	[RMLCT25_23] [decimal](10, 4) NULL,
	[RMLCT25_24] [decimal](10, 4) NULL,
	[RMLCT25_25] [decimal](10, 4) NULL,
	[RMLCT25_26] [decimal](10, 4) NULL,
	[RMLCT25_27] [decimal](10, 4) NULL,
	[RMLCT25_28] [tinyint] NULL,
	[RMLCT25_29] [tinyint] NULL,
	[RMLCT25_30] [tinyint] NULL,
	[RMLCT25_31] [tinyint] NULL,
	[RMLCT25_32] [tinyint] NULL,
	[RMLCT25_33] [tinyint] NULL,
	[RMLCT25_34] [tinyint] NULL,
	[RMLCT25_35] [tinyint] NULL,
	[RMLCT25_36] [tinyint] NULL,
	[RMLCT25_37] [tinyint] NULL,
	[RMLCT25_38] [tinyint] NULL,
	[RMLCT25_39] [tinyint] NULL,
	[RMLCT25_40] [decimal](10, 4) NULL,
	[RMLCT25_41] [decimal](10, 4) NULL,
	[RMLCT25_42] [decimal](10, 4) NULL,
	[RMLCT25_43] [decimal](10, 4) NULL,
	[RMLCT25_44] [decimal](10, 4) NULL,
	[RMLCT25_45] [decimal](10, 4) NULL,
	[CreadoPor] [int] NULL,
	[CreadoEl] [datetime] NULL,
 CONSTRAINT [PK_SIPAC_ImportRML_CONT_25_M] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[SIPAC_ImportRML_CONT_25_M]  WITH CHECK ADD  CONSTRAINT [FK_SIPAC_ImportRML_CONT_25_M_AP_Usuario] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
GO

ALTER TABLE [dbo].[SIPAC_ImportRML_CONT_25_M] CHECK CONSTRAINT [FK_SIPAC_ImportRML_CONT_25_M_AP_Usuario]
GO

ALTER TABLE [dbo].[SIPAC_ImportRML_CONT_25_M]  WITH CHECK ADD  CONSTRAINT [FK_SIPAC_ImportRML_CONT_25_M_SIPAC_ImportBitacora] FOREIGN KEY([IdBitacora])
REFERENCES [dbo].[SIPAC_ImportBitacora] ([Id])
GO

ALTER TABLE [dbo].[SIPAC_ImportRML_CONT_25_M] CHECK CONSTRAINT [FK_SIPAC_ImportRML_CONT_25_M_SIPAC_ImportBitacora]
GO


